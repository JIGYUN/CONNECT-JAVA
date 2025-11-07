// filepath: src/shared/push/adapters.ts
import type { PushEntry } from '@/shared/push/types';

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
export function adaptInPush(row: unknown): PushEntry {
    const o = unwrapRow(row);
    const msgIdField = pickNum(o, ["MSG_ID","msgId"]);
    const grpCdField = pickStr(o, ["GRP_CD","grpCd"]);
    const titleField = pickStr(o, ["TITLE","title"]);
    const bodyTxtField = pickStr(o, ["BODY_TXT","bodyTxt"]);
    const imageUrlField = pickStr(o, ["IMAGE_URL","imageUrl"]);
    const clickUrlField = pickStr(o, ["CLICK_URL","clickUrl"]);
    const targetTypeCdField = pickStr(o, ["TARGET_TYPE_CD","targetTypeCd"]);
    const targetUserIdField = pickNum(o, ["TARGET_USER_ID","targetUserId"]);
    const targetGrpCdField = pickStr(o, ["TARGET_GRP_CD","targetGrpCd"]);
    const topicNameField = pickStr(o, ["TOPIC_NAME","topicName"]);
    const tokensJsonField = pickStr(o, ["TOKENS_JSON","tokensJson"]);
    const dataJsonField = pickStr(o, ["DATA_JSON","dataJson"]);
    const priorityCdField = pickStr(o, ["PRIORITY_CD","priorityCd"]);
    const ttlSecField = pickNum(o, ["TTL_SEC","ttlSec"]);
    const scheduleDtField = pickStr(o, ["SCHEDULE_DT","scheduleDt"]);
    const statusCdField = pickStr(o, ["STATUS_CD","statusCd"]);
    const targetCntField = pickNum(o, ["TARGET_CNT","targetCnt"]);
    const successCntField = pickNum(o, ["SUCCESS_CNT","successCnt"]);
    const failCntField = pickNum(o, ["FAIL_CNT","failCnt"]);
    const sendStartDtField = pickStr(o, ["SEND_START_DT","sendStartDt"]);
    const sendEndDtField = pickStr(o, ["SEND_END_DT","sendEndDt"]);
    const lastErrorSummaryField = pickStr(o, ["LAST_ERROR_SUMMARY","lastErrorSummary"]);
    const respSummaryJsonField = pickStr(o, ["RESP_SUMMARY_JSON","respSummaryJson"]);
    const useAtField = pickStr(o, ["USE_AT","useAt"]);
    const createdDtField = pickStr(o, ["CREATED_DT","createdDt"]);
    const createdByField = pickNum(o, ["CREATED_BY","createdBy"]);
    const updatedDtField = pickStr(o, ["UPDATED_DT","updatedDt"]);
    const updatedByField = pickNum(o, ["UPDATED_BY","updatedBy"]);

    return {
        msgId: msgIdField ?? null,
        grpCd: grpCdField ?? null,
        title: titleField ?? null,
        bodyTxt: bodyTxtField ?? null,
        imageUrl: imageUrlField ?? null,
        clickUrl: clickUrlField ?? null,
        targetTypeCd: targetTypeCdField ?? null,
        targetUserId: targetUserIdField ?? null,
        targetGrpCd: targetGrpCdField ?? null,
        topicName: topicNameField ?? null,
        tokensJson: tokensJsonField ?? null,
        dataJson: dataJsonField ?? null,
        priorityCd: priorityCdField ?? null,
        ttlSec: ttlSecField ?? null,
        scheduleDt: scheduleDtField ?? null,
        statusCd: statusCdField ?? null,
        targetCnt: targetCntField ?? null,
        successCnt: successCntField ?? null,
        failCnt: failCntField ?? null,
        sendStartDt: sendStartDtField ?? null,
        sendEndDt: sendEndDtField ?? null,
        lastErrorSummary: lastErrorSummaryField ?? null,
        respSummaryJson: respSummaryJsonField ?? null,
        useAt: useAtField ?? null,
        createdDt: createdDtField ?? null,
        createdBy: createdByField ?? null,
        updatedDt: updatedDtField ?? null,
        updatedBy: updatedByField ?? null,
    };
}

/** 프런트 → 서버 (업서트/전송용) */
export function adaptOutPush(input: PushEntry): Record<string, unknown> {
    return {
        MSG_ID: input.msgId ?? null,
        GRP_CD: input.grpCd ?? null,
        TITLE: input.title ?? null,
        BODY_TXT: input.bodyTxt ?? null,
        IMAGE_URL: input.imageUrl ?? null,
        CLICK_URL: input.clickUrl ?? null,
        TARGET_TYPE_CD: input.targetTypeCd ?? null,
        TARGET_USER_ID: input.targetUserId ?? null,
        TARGET_GRP_CD: input.targetGrpCd ?? null,
        TOPIC_NAME: input.topicName ?? null,
        TOKENS_JSON: input.tokensJson ?? null,
        DATA_JSON: input.dataJson ?? null,
        PRIORITY_CD: input.priorityCd ?? null,
        TTL_SEC: input.ttlSec ?? null,
        SCHEDULE_DT: input.scheduleDt ?? null,
        STATUS_CD: input.statusCd ?? null,
        TARGET_CNT: input.targetCnt ?? null,
        SUCCESS_CNT: input.successCnt ?? null,
        FAIL_CNT: input.failCnt ?? null,
        SEND_START_DT: input.sendStartDt ?? null,
        SEND_END_DT: input.sendEndDt ?? null,
        LAST_ERROR_SUMMARY: input.lastErrorSummary ?? null,
        RESP_SUMMARY_JSON: input.respSummaryJson ?? null,
        USE_AT: input.useAt ?? null,
        CREATED_DT: input.createdDt ?? null,
        CREATED_BY: input.createdBy ?? null,
        UPDATED_DT: input.updatedDt ?? null,
        UPDATED_BY: input.updatedBy ?? null,
    };
}
