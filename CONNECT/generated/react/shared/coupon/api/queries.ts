// filepath: src/shared/coupon/api/queries.ts
import { useQuery, useMutation, useQueryClient, type QueryKey } from '@tanstack/react-query';
import { postJson } from '@/shared/core/apiClient';
import type { CouponEntry, CouponUpsertInput } from '@/shared/coupon/types';
import { adaptInCoupon } from '@/shared/coupon/adapters';

const isRec = (v: unknown): v is Record<string, unknown> => typeof v === 'object' && v !== null;

const normGrp = (g?: string | null) => (g && g.trim() ? g : null);
const normOwner = (o?: number | null) => (typeof o === 'number' && Number.isFinite(o) ? o : null);

function keyCouponByDate(diaryDt: string, grpCd?: string | null, ownerId?: number | null): QueryKey {
    return ['coupon/byDate', diaryDt, normGrp(grpCd), normOwner(ownerId)];
}

/** 서버 응답 → 첫 레코드 추출 */
function extractOne(v: unknown): CouponEntry | null {
    const unwrapList = (x: unknown): unknown => {
        if (Array.isArray(x)) return x;
        if (isRec(x) && Array.isArray(x['result'])) return x['result'];
        if (isRec(x) && Array.isArray(x['rows']))   return x['rows'];
        if (isRec(x) && Array.isArray(x['list']))   return x['list'];
        return x;
    };

    let cur: unknown = v;
    for (let i = 0; i < 5; i++) {
        const list = unwrapList(cur);
        if (Array.isArray(list)) {
            return list.length ? adaptInCoupon(list[0]) : null;
        }
        if (
            isRec(cur) &&
            (isRec(cur['result']) || isRec(cur['data']) || isRec(cur['item']))
        ) {
            cur = (cur['result'] as unknown)
               || (cur['data'] as unknown)
               || (cur['item'] as unknown);
            continue;
        }
        break;
    }
    return isRec(cur) ? adaptInCoupon(cur) : null;
}

const API = {
    selectByDate: '/api/cop/coupon/selectCouponByDate',
    upsert:       '/api/cop/coupon/upsertCoupon',
};

async function getByDate(diaryDt: string, grpCd?: string | null, ownerId?: number | null): Promise<CouponEntry | null> {
    const payload = {
        diaryDt,
        grpCd: normGrp(grpCd),
        ownerId: normOwner(ownerId),
    };
    const data = await postJson<unknown>(API.selectByDate, payload);
    return extractOne(data);
}

export function useCouponByDate(p: { diaryDt: string; grpCd?: string | null; ownerId?: number | null }) {
    const diaryDt = p.diaryDt;
    const grpCd   = normGrp(p.grpCd ?? null);
    const ownerId = normOwner(p.ownerId ?? null);

    return useQuery<CouponEntry | null, Error>({
        queryKey: keyCouponByDate(diaryDt, grpCd, ownerId),
        queryFn: () => getByDate(diaryDt, grpCd, ownerId),
        enabled: !!diaryDt && ownerId !== null,
        retry: 0,
        refetchOnWindowFocus: false,
        refetchOnReconnect: false,
        staleTime: 2000,
    });
}

export function useUpsertCoupon(ctx: { grpCd?: string | null; ownerId?: number | null }) {
    const qc = useQueryClient();
    const grpCd   = normGrp(ctx.grpCd ?? null);
    const ownerId = normOwner(ctx.ownerId ?? null);

    return useMutation<void, Error, CouponUpsertInput>({
        mutationFn: async (input) => {
            const body: CouponUpsertInput = {
                diaryDt: input.diaryDt,
                content: (input as Record<string, unknown>)['content'] as string,
                grpCd:   (input as Record<string, unknown>)['grpCd'] ?? grpCd ?? null,
                ownerId: normOwner(((input as Record<string, unknown>)['ownerId'] as number | null) ?? ownerId),
            };
            await postJson<unknown>(API.upsert, body);
        },
        onSuccess: (_d, v) => {
            const keyDate = (v as Record<string, unknown>)['diaryDt'];
            const keyStr = typeof keyDate === 'string' ? keyDate.slice(0,10) : '';
            if (keyStr) {
                qc.invalidateQueries({ queryKey: keyCouponByDate(keyStr, grpCd, ownerId) });
            } else {
                qc.invalidateQueries({ queryKey: ['coupon/byDate'] });
            }
        },
    });
}
