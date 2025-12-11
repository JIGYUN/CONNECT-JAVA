// filepath: src/shared/couponUser/adapters.ts
import type { CouponUserEntry } from '@/shared/couponUser/types';

const isRec = (v: unknown): v is Record<string, unknown> =>
    typeof v === 'object' && v !== null;

function pickStr(o: Record<string, unknown>, keys: string[]): string | null {
    for (const k of keys) {
        const v = o[k];
        if (typeof v === 'string' && v.trim() !== '') return v;
    }
    return null;
}

function pickNum(o: Record<String, unknown>, keys: string[]): number | null {
    for (const k of keys) {
        const v = o[k];
        if (typeof v === 'number' && Number.isFinite(v)) return v;
        if (typeof v === 'string') {
            const n = Number(v);
            if (Number.isFinite(n)) return n;
        }
    }
    return null;
}

/** result/data/item 래핑을 최대 5단계 언랩 */
function unwrapRow(row: unknown): Record<string, unknown> {
    let cur: unknown = row;
    for (let i = 0; i < 5; i++) {
        if (!isRec(cur)) break;
        const next =
            (isRec(cur['result']) && cur['result']) ||
            (isRec(cur['data']) && cur['data'])   ||
            (isRec(cur['item']) && cur['item']);
        if (next) {
            cur = next;
            continue;
        }
        break;
    }
    return isRec(cur) ? cur : {};
}

/** 서버 → 프런트 표준화 */
export function adaptInCouponUser(row: unknown): CouponUserEntry {
    const o = unwrapRow(row);
    const idField = pickNum(o, ["COUPON_USER_ID","couponUserId","id","ID"]);
    const couponIdField = pickNum(o, ["COUPON_ID","couponId"]);
    const userIdField = pickNum(o, ["USER_ID","userId"]);
    const issueDtField = pickStr(o, ["ISSUE_DT","issueDt"]);
    const useDtField = pickStr(o, ["USE_DT","useDt"]);
    const statusCdField = pickStr(o, ["STATUS_CD","statusCd"]);
    const orderIdField = pickNum(o, ["ORDER_ID","orderId"]);
    const useAtField = pickStr(o, ["USE_AT","useAt"]);
    const createdDtField = pickStr(o, ["CREATED_DT","createdDt"]);
    const createdByField = pickNum(o, ["CREATED_BY","createdBy"]);
    const updatedDtField = pickStr(o, ["UPDATED_DT","updatedDt"]);
    const updatedByField = pickNum(o, ["UPDATED_BY","updatedBy"]);

    return {
        id: idField ?? null,
        couponId: couponIdField ?? null,
        userId: userIdField ?? null,
        issueDt: issueDtField ?? null,
        useDt: useDtField ?? null,
        statusCd: statusCdField ?? null,
        orderId: orderIdField ?? null,
        useAt: useAtField ?? null,
        createdDt: createdDtField ?? null,
        createdBy: createdByField ?? null,
        updatedDt: updatedDtField ?? null,
        updatedBy: updatedByField ?? null,
    };
}

/** 프런트 → 서버 (업서트/전송용) */
export function adaptOutCouponUser(input: CouponUserEntry): Record<string, unknown> {
    return {
        COUPON_USER_ID: input.id ?? null,
        COUPON_ID: input.couponId ?? null,
        USER_ID: input.userId ?? null,
        ISSUE_DT: input.issueDt ?? null,
        USE_DT: input.useDt ?? null,
        STATUS_CD: input.statusCd ?? null,
        ORDER_ID: input.orderId ?? null,
        USE_AT: input.useAt ?? null,
        CREATED_DT: input.createdDt ?? null,
        CREATED_BY: input.createdBy ?? null,
        UPDATED_DT: input.updatedDt ?? null,
        UPDATED_BY: input.updatedBy ?? null,
    };
}
