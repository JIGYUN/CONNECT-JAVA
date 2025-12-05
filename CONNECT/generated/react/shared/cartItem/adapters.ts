// filepath: src/shared/cartItem/adapters.ts
import type { CartItemEntry } from '@/shared/cartItem/types';

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
export function adaptInCartItem(row: unknown): CartItemEntry {
    const o = unwrapRow(row);
    const idField = pickNum(o, ["CART_ITEM_ID","cartItemId","id","ID"]);
    const cartIdField = pickNum(o, ["CART_ID","cartId"]);
    const productIdField = pickNum(o, ["PRODUCT_ID","productId"]);
    const qtyField = pickNum(o, ["QTY","qty"]);
    const unitPriceField = pickStr(o, ["UNIT_PRICE","unitPrice"]);
    const discountAmtField = pickStr(o, ["DISCOUNT_AMT","discountAmt"]);
    const lineAmtField = pickStr(o, ["LINE_AMT","lineAmt"]);
    const optionJsonField = pickStr(o, ["OPTION_JSON","optionJson"]);
    const useAtField = pickStr(o, ["USE_AT","useAt"]);
    const createdDtField = pickStr(o, ["CREATED_DT","createdDt"]);
    const createdByField = pickNum(o, ["CREATED_BY","createdBy"]);
    const updatedDtField = pickStr(o, ["UPDATED_DT","updatedDt"]);
    const updatedByField = pickNum(o, ["UPDATED_BY","updatedBy"]);

    return {
        id: idField ?? null,
        cartId: cartIdField ?? null,
        productId: productIdField ?? null,
        qty: qtyField ?? null,
        unitPrice: unitPriceField ?? null,
        discountAmt: discountAmtField ?? null,
        lineAmt: lineAmtField ?? null,
        optionJson: optionJsonField ?? null,
        useAt: useAtField ?? null,
        createdDt: createdDtField ?? null,
        createdBy: createdByField ?? null,
        updatedDt: updatedDtField ?? null,
        updatedBy: updatedByField ?? null,
    };
}

/** 프런트 → 서버 (업서트/전송용) */
export function adaptOutCartItem(input: CartItemEntry): Record<string, unknown> {
    return {
        CART_ITEM_ID: input.id ?? null,
        CART_ID: input.cartId ?? null,
        PRODUCT_ID: input.productId ?? null,
        QTY: input.qty ?? null,
        UNIT_PRICE: input.unitPrice ?? null,
        DISCOUNT_AMT: input.discountAmt ?? null,
        LINE_AMT: input.lineAmt ?? null,
        OPTION_JSON: input.optionJson ?? null,
        USE_AT: input.useAt ?? null,
        CREATED_DT: input.createdDt ?? null,
        CREATED_BY: input.createdBy ?? null,
        UPDATED_DT: input.updatedDt ?? null,
        UPDATED_BY: input.updatedBy ?? null,
    };
}
