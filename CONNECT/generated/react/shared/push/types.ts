// filepath: src/shared/push/types.ts
import type { Id } from '@/shared/types/common';

/**
 * PushEntry
 * - DB 테이블 TB_PUSH 기반 자동생성
 * - PK: MSG_ID
 */
export type PushEntry = {
    msgId?: number | null;
    grpCd?: string | null;
    title?: string | null;
    bodyTxt?: string | null;
    imageUrl?: string | null;
    clickUrl?: string | null;
    targetTypeCd?: string | null;
    targetUserId?: number | null;
    targetGrpCd?: string | null;
    topicName?: string | null;
    tokensJson?: string | null;
    dataJson?: string | null;
    priorityCd?: string | null;
    ttlSec?: number | null;
    scheduleDt?: string | null;
    statusCd?: string | null;
    targetCnt?: number | null;
    successCnt?: number | null;
    failCnt?: number | null;
    sendStartDt?: string | null;
    sendEndDt?: string | null;
    lastErrorSummary?: string | null;
    respSummaryJson?: string | null;
    useAt?: string | null;
    createdDt?: string | null;
    createdBy?: number | null;
    updatedDt?: string | null;
    updatedBy?: number | null;
};

/**
 * PushUpsertInput
 * - 업서트 API 파라미터 표준
 */
export type PushUpsertInput = {
    diaryDt: string;
    content: string;
    grpCd?: string | null;
    ownerId?: Id | null;
};
