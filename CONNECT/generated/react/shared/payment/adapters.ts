// filepath: src/shared/payment/adapters.ts
import type { PaymentEntry } from '@/shared/payment/types';

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
export function adaptInPayment(row: unknown): PaymentEntry {
    const o = unwrapRow(row);
    const idField = pickNum(o, ["PAYMENT_ID","paymentId","id","ID"]);
    const orderIdField = pickNum(o, ["ORDER_ID","orderId"]);
    const pgCdField = pickStr(o, ["PG_CD","pgCd"]);
    const pgMidField = pickStr(o, ["PG_MID","pgMid"]);
    const pgTidField = pickStr(o, ["PG_TID","pgTid"]);
    const payMethodCdField = pickStr(o, ["PAY_METHOD_CD","payMethodCd"]);
    const payTotalAmtField = pickStr(o, ["PAY_TOTAL_AMT","payTotalAmt"]);
    const payApprovedAmtField = pickStr(o, ["PAY_APPROVED_AMT","payApprovedAmt"]);
    const payStatusCdField = pickStr(o, ["PAY_STATUS_CD","payStatusCd"]);
    const reqDtField = pickStr(o, ["REQ_DT","reqDt"]);
    const resDtField = pickStr(o, ["RES_DT","resDt"]);
    const rawRequestJsonField = pickStr(o, ["RAW_REQUEST_JSON","rawRequestJson"]);
    const rawResponseJsonField = pickStr(o, ["RAW_RESPONSE_JSON","rawResponseJson"]);
    const useAtField = pickStr(o, ["USE_AT","useAt"]);
    const createdDtField = pickStr(o, ["CREATED_DT","createdDt"]);
    const createdByField = pickNum(o, ["CREATED_BY","createdBy"]);
    const updatedDtField = pickStr(o, ["UPDATED_DT","updatedDt"]);
    const updatedByField = pickNum(o, ["UPDATED_BY","updatedBy"]);

    return {
        id: idField ?? null,
        orderId: orderIdField ?? null,
        pgCd: pgCdField ?? null,
        pgMid: pgMidField ?? null,
        pgTid: pgTidField ?? null,
        payMethodCd: payMethodCdField ?? null,
        payTotalAmt: payTotalAmtField ?? null,
        payApprovedAmt: payApprovedAmtField ?? null,
        payStatusCd: payStatusCdField ?? null,
        reqDt: reqDtField ?? null,
        resDt: resDtField ?? null,
        rawRequestJson: rawRequestJsonField ?? null,
        rawResponseJson: rawResponseJsonField ?? null,
        useAt: useAtField ?? null,
        createdDt: createdDtField ?? null,
        createdBy: createdByField ?? null,
        updatedDt: updatedDtField ?? null,
        updatedBy: updatedByField ?? null,
    };
}

/** 프런트 → 서버 (업서트/전송용) */
export function adaptOutPayment(input: PaymentEntry): Record<string, unknown> {
    return {
        PAYMENT_ID: input.id ?? null,
        ORDER_ID: input.orderId ?? null,
        PG_CD: input.pgCd ?? null,
        PG_MID: input.pgMid ?? null,
        PG_TID: input.pgTid ?? null,
        PAY_METHOD_CD: input.payMethodCd ?? null,
        PAY_TOTAL_AMT: input.payTotalAmt ?? null,
        PAY_APPROVED_AMT: input.payApprovedAmt ?? null,
        PAY_STATUS_CD: input.payStatusCd ?? null,
        REQ_DT: input.reqDt ?? null,
        RES_DT: input.resDt ?? null,
        RAW_REQUEST_JSON: input.rawRequestJson ?? null,
        RAW_RESPONSE_JSON: input.rawResponseJson ?? null,
        USE_AT: input.useAt ?? null,
        CREATED_DT: input.createdDt ?? null,
        CREATED_BY: input.createdBy ?? null,
        UPDATED_DT: input.updatedDt ?? null,
        UPDATED_BY: input.updatedBy ?? null,
    };
}
