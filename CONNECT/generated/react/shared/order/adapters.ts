// filepath: src/shared/order/adapters.ts
import type { OrderEntry } from '@/shared/order/types';

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
export function adaptInOrder(row: unknown): OrderEntry {
    const o = unwrapRow(row);
    const idField = pickNum(o, ["ORDER_ID","orderId","id","ID"]);
    const orderNoField = pickStr(o, ["ORDER_NO","orderNo"]);
    const userIdField = pickNum(o, ["USER_ID","userId"]);
    const orderStatusCdField = pickStr(o, ["ORDER_STATUS_CD","orderStatusCd"]);
    const payStatusCdField = pickStr(o, ["PAY_STATUS_CD","payStatusCd"]);
    const payMethodCdField = pickStr(o, ["PAY_METHOD_CD","payMethodCd"]);
    const totalProductAmtField = pickStr(o, ["TOTAL_PRODUCT_AMT","totalProductAmt"]);
    const totalDiscountAmtField = pickStr(o, ["TOTAL_DISCOUNT_AMT","totalDiscountAmt"]);
    const deliveryAmtField = pickStr(o, ["DELIVERY_AMT","deliveryAmt"]);
    const orderAmtField = pickStr(o, ["ORDER_AMT","orderAmt"]);
    const pointUseAmtField = pickStr(o, ["POINT_USE_AMT","pointUseAmt"]);
    const pointSaveAmtField = pickStr(o, ["POINT_SAVE_AMT","pointSaveAmt"]);
    const couponUseAmtField = pickStr(o, ["COUPON_USE_AMT","couponUseAmt"]);
    const payAmtField = pickStr(o, ["PAY_AMT","payAmt"]);
    const receiverNmField = pickStr(o, ["RECEIVER_NM","receiverNm"]);
    const receiverPhoneField = pickStr(o, ["RECEIVER_PHONE","receiverPhone"]);
    const zipCodeField = pickStr(o, ["ZIP_CODE","zipCode"]);
    const addr1Field = pickStr(o, ["ADDR1","addr1"]);
    const addr2Field = pickStr(o, ["ADDR2","addr2"]);
    const deliveryMemoField = pickStr(o, ["DELIVERY_MEMO","deliveryMemo"]);
    const useAtField = pickStr(o, ["USE_AT","useAt"]);
    const createdDtField = pickStr(o, ["CREATED_DT","createdDt"]);
    const createdByField = pickNum(o, ["CREATED_BY","createdBy"]);
    const updatedDtField = pickStr(o, ["UPDATED_DT","updatedDt"]);
    const updatedByField = pickNum(o, ["UPDATED_BY","updatedBy"]);

    return {
        id: idField ?? null,
        orderNo: orderNoField ?? null,
        userId: userIdField ?? null,
        orderStatusCd: orderStatusCdField ?? null,
        payStatusCd: payStatusCdField ?? null,
        payMethodCd: payMethodCdField ?? null,
        totalProductAmt: totalProductAmtField ?? null,
        totalDiscountAmt: totalDiscountAmtField ?? null,
        deliveryAmt: deliveryAmtField ?? null,
        orderAmt: orderAmtField ?? null,
        pointUseAmt: pointUseAmtField ?? null,
        pointSaveAmt: pointSaveAmtField ?? null,
        couponUseAmt: couponUseAmtField ?? null,
        payAmt: payAmtField ?? null,
        receiverNm: receiverNmField ?? null,
        receiverPhone: receiverPhoneField ?? null,
        zipCode: zipCodeField ?? null,
        addr1: addr1Field ?? null,
        addr2: addr2Field ?? null,
        deliveryMemo: deliveryMemoField ?? null,
        useAt: useAtField ?? null,
        createdDt: createdDtField ?? null,
        createdBy: createdByField ?? null,
        updatedDt: updatedDtField ?? null,
        updatedBy: updatedByField ?? null,
    };
}

/** 프런트 → 서버 (업서트/전송용) */
export function adaptOutOrder(input: OrderEntry): Record<string, unknown> {
    return {
        ORDER_ID: input.id ?? null,
        ORDER_NO: input.orderNo ?? null,
        USER_ID: input.userId ?? null,
        ORDER_STATUS_CD: input.orderStatusCd ?? null,
        PAY_STATUS_CD: input.payStatusCd ?? null,
        PAY_METHOD_CD: input.payMethodCd ?? null,
        TOTAL_PRODUCT_AMT: input.totalProductAmt ?? null,
        TOTAL_DISCOUNT_AMT: input.totalDiscountAmt ?? null,
        DELIVERY_AMT: input.deliveryAmt ?? null,
        ORDER_AMT: input.orderAmt ?? null,
        POINT_USE_AMT: input.pointUseAmt ?? null,
        POINT_SAVE_AMT: input.pointSaveAmt ?? null,
        COUPON_USE_AMT: input.couponUseAmt ?? null,
        PAY_AMT: input.payAmt ?? null,
        RECEIVER_NM: input.receiverNm ?? null,
        RECEIVER_PHONE: input.receiverPhone ?? null,
        ZIP_CODE: input.zipCode ?? null,
        ADDR1: input.addr1 ?? null,
        ADDR2: input.addr2 ?? null,
        DELIVERY_MEMO: input.deliveryMemo ?? null,
        USE_AT: input.useAt ?? null,
        CREATED_DT: input.createdDt ?? null,
        CREATED_BY: input.createdBy ?? null,
        UPDATED_DT: input.updatedDt ?? null,
        UPDATED_BY: input.updatedBy ?? null,
    };
}
