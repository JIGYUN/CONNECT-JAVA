// filepath: src/shared/coupon/adapters.ts
import type { CouponEntry } from '@/shared/coupon/types';

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
export function adaptInCoupon(row: unknown): CouponEntry {
    const o = unwrapRow(row);
    const idField = pickNum(o, ["COUPON_ID","couponId","id","ID"]);
    const couponCdField = pickStr(o, ["COUPON_CD","couponCd"]);
    const couponNmField = pickStr(o, ["COUPON_NM","couponNm"]);
    const couponTypeCdField = pickStr(o, ["COUPON_TYPE_CD","couponTypeCd"]);
    const discountRateField = pickStr(o, ["DISCOUNT_RATE","discountRate"]);
    const discountAmtField = pickStr(o, ["DISCOUNT_AMT","discountAmt"]);
    const maxDiscountAmtField = pickStr(o, ["MAX_DISCOUNT_AMT","maxDiscountAmt"]);
    const minOrderAmtField = pickStr(o, ["MIN_ORDER_AMT","minOrderAmt"]);
    const maxIssueCntField = pickNum(o, ["MAX_ISSUE_CNT","maxIssueCnt"]);
    const perUserMaxCntField = pickNum(o, ["PER_USER_MAX_CNT","perUserMaxCnt"]);
    const startDtField = pickStr(o, ["START_DT","startDt"]);
    const endDtField = pickStr(o, ["END_DT","endDt"]);
    const useAtField = pickStr(o, ["USE_AT","useAt"]);
    const memoField = pickStr(o, ["MEMO","memo"]);
    const createdDtField = pickStr(o, ["CREATED_DT","createdDt"]);
    const createdByField = pickNum(o, ["CREATED_BY","createdBy"]);
    const updatedDtField = pickStr(o, ["UPDATED_DT","updatedDt"]);
    const updatedByField = pickNum(o, ["UPDATED_BY","updatedBy"]);

    return {
        id: idField ?? null,
        couponCd: couponCdField ?? null,
        couponNm: couponNmField ?? null,
        couponTypeCd: couponTypeCdField ?? null,
        discountRate: discountRateField ?? null,
        discountAmt: discountAmtField ?? null,
        maxDiscountAmt: maxDiscountAmtField ?? null,
        minOrderAmt: minOrderAmtField ?? null,
        maxIssueCnt: maxIssueCntField ?? null,
        perUserMaxCnt: perUserMaxCntField ?? null,
        startDt: startDtField ?? null,
        endDt: endDtField ?? null,
        useAt: useAtField ?? null,
        memo: memoField ?? null,
        createdDt: createdDtField ?? null,
        createdBy: createdByField ?? null,
        updatedDt: updatedDtField ?? null,
        updatedBy: updatedByField ?? null,
    };
}

/** 프런트 → 서버 (업서트/전송용) */
export function adaptOutCoupon(input: CouponEntry): Record<string, unknown> {
    return {
        COUPON_ID: input.id ?? null,
        COUPON_CD: input.couponCd ?? null,
        COUPON_NM: input.couponNm ?? null,
        COUPON_TYPE_CD: input.couponTypeCd ?? null,
        DISCOUNT_RATE: input.discountRate ?? null,
        DISCOUNT_AMT: input.discountAmt ?? null,
        MAX_DISCOUNT_AMT: input.maxDiscountAmt ?? null,
        MIN_ORDER_AMT: input.minOrderAmt ?? null,
        MAX_ISSUE_CNT: input.maxIssueCnt ?? null,
        PER_USER_MAX_CNT: input.perUserMaxCnt ?? null,
        START_DT: input.startDt ?? null,
        END_DT: input.endDt ?? null,
        USE_AT: input.useAt ?? null,
        MEMO: input.memo ?? null,
        CREATED_DT: input.createdDt ?? null,
        CREATED_BY: input.createdBy ?? null,
        UPDATED_DT: input.updatedDt ?? null,
        UPDATED_BY: input.updatedBy ?? null,
    };
}
