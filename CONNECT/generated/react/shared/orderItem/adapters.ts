// filepath: src/shared/orderItem/adapters.ts
import type { OrderItemEntry } from '@/shared/orderItem/types';

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
export function adaptInOrderItem(row: unknown): OrderItemEntry {
    const o = unwrapRow(row);
    const idField = pickNum(o, ["ORDER_ITEM_ID","orderItemId","id","ID"]);
    const orderIdField = pickNum(o, ["ORDER_ID","orderId"]);
    const productIdField = pickNum(o, ["PRODUCT_ID","productId"]);
    const productNmField = pickStr(o, ["PRODUCT_NM","productNm"]);
    const qtyField = pickNum(o, ["QTY","qty"]);
    const unitPriceField = pickStr(o, ["UNIT_PRICE","unitPrice"]);
    const discountAmtField = pickStr(o, ["DISCOUNT_AMT","discountAmt"]);
    const lineAmtField = pickStr(o, ["LINE_AMT","lineAmt"]);
    const statusCdField = pickStr(o, ["STATUS_CD","statusCd"]);
    const optionJsonField = pickStr(o, ["OPTION_JSON","optionJson"]);
    const useAtField = pickStr(o, ["USE_AT","useAt"]);
    const createdDtField = pickStr(o, ["CREATED_DT","createdDt"]);
    const createdByField = pickNum(o, ["CREATED_BY","createdBy"]);
    const updatedDtField = pickStr(o, ["UPDATED_DT","updatedDt"]);
    const updatedByField = pickNum(o, ["UPDATED_BY","updatedBy"]);

    return {
        id: idField ?? null,
        orderId: orderIdField ?? null,
        productId: productIdField ?? null,
        productNm: productNmField ?? null,
        qty: qtyField ?? null,
        unitPrice: unitPriceField ?? null,
        discountAmt: discountAmtField ?? null,
        lineAmt: lineAmtField ?? null,
        statusCd: statusCdField ?? null,
        optionJson: optionJsonField ?? null,
        useAt: useAtField ?? null,
        createdDt: createdDtField ?? null,
        createdBy: createdByField ?? null,
        updatedDt: updatedDtField ?? null,
        updatedBy: updatedByField ?? null,
    };
}

/** 프런트 → 서버 (업서트/전송용) */
export function adaptOutOrderItem(input: OrderItemEntry): Record<string, unknown> {
    return {
        ORDER_ITEM_ID: input.id ?? null,
        ORDER_ID: input.orderId ?? null,
        PRODUCT_ID: input.productId ?? null,
        PRODUCT_NM: input.productNm ?? null,
        QTY: input.qty ?? null,
        UNIT_PRICE: input.unitPrice ?? null,
        DISCOUNT_AMT: input.discountAmt ?? null,
        LINE_AMT: input.lineAmt ?? null,
        STATUS_CD: input.statusCd ?? null,
        OPTION_JSON: input.optionJson ?? null,
        USE_AT: input.useAt ?? null,
        CREATED_DT: input.createdDt ?? null,
        CREATED_BY: input.createdBy ?? null,
        UPDATED_DT: input.updatedDt ?? null,
        UPDATED_BY: input.updatedBy ?? null,
    };
}
