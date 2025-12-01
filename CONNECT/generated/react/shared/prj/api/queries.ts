// filepath: src/shared/prj/api/queries.ts
import { useQuery, useMutation, useQueryClient, type QueryKey } from '@tanstack/react-query';
import { postJson } from '@/shared/core/apiClient';
import type { prjEntry, prjUpsertInput } from '@/shared/prj/types';
import { adaptInprj } from '@/shared/prj/adapters';

const isRec = (v: unknown): v is Record<string, unknown> => typeof v === 'object' && v !== null;

const normGrp = (g?: string | null) => (g && g.trim() ? g : null);
const normOwner = (o?: number | null) => (typeof o === 'number' && Number.isFinite(o) ? o : null);

function keyprjByDate(diaryDt: string, grpCd?: string | null, ownerId?: number | null): QueryKey {
    return ['prj/byDate', diaryDt, normGrp(grpCd), normOwner(ownerId)];
}

/** 서버 응답 → 첫 레코드 추출 */
function extractOne(v: unknown): prjEntry | null {
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
            return list.length ? adaptInprj(list[0]) : null;
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
    return isRec(cur) ? adaptInprj(cur) : null;
}

const API = {
    selectByDate: '/api/isu/prj/selectprjByDate',
    upsert:       '/api/isu/prj/upsertprj',
};

async function getByDate(diaryDt: string, grpCd?: string | null, ownerId?: number | null): Promise<prjEntry | null> {
    const payload = {
        diaryDt,
        grpCd: normGrp(grpCd),
        ownerId: normOwner(ownerId),
    };
    const data = await postJson<unknown>(API.selectByDate, payload);
    return extractOne(data);
}

export function useprjByDate(p: { diaryDt: string; grpCd?: string | null; ownerId?: number | null }) {
    const diaryDt = p.diaryDt;
    const grpCd   = normGrp(p.grpCd ?? null);
    const ownerId = normOwner(p.ownerId ?? null);

    return useQuery<prjEntry | null, Error>({
        queryKey: keyprjByDate(diaryDt, grpCd, ownerId),
        queryFn: () => getByDate(diaryDt, grpCd, ownerId),
        enabled: !!diaryDt && ownerId !== null,
        retry: 0,
        refetchOnWindowFocus: false,
        refetchOnReconnect: false,
        staleTime: 2000,
    });
}

export function useUpsertprj(ctx: { grpCd?: string | null; ownerId?: number | null }) {
    const qc = useQueryClient();
    const grpCd   = normGrp(ctx.grpCd ?? null);
    const ownerId = normOwner(ctx.ownerId ?? null);

    return useMutation<void, Error, prjUpsertInput>({
        mutationFn: async (input) => {
            const body: prjUpsertInput = {
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
                qc.invalidateQueries({ queryKey: keyprjByDate(keyStr, grpCd, ownerId) });
            } else {
                qc.invalidateQueries({ queryKey: ['prj/byDate'] });
            }
        },
    });
}
