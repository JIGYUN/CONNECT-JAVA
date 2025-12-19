// filepath: src/shared/testt/types.ts
import type { Id } from '@/shared/types/common';

/**
 * TesttEntry
 * - DB 테이블 TB_TESTT 기반 자동생성
 * - PK: TESTT_IDX
 */
export type TesttEntry = {
    id?: Id | null;
    grpCd?: string | null;
    boardCd?: string | null;
    categoryCd?: string | null;
    statusCd?: string | null;
    noticeAt?: string | null;
    pinAt?: string | null;
    secretAt?: string | null;
    title?: string | null;
    subTitle?: string | null;
    summaryTxt?: string | null;
    contentHtml?: number | null;
    tags?: string | null;
    thumbUrl?: string | null;
    attachJson?: number | null;
    publishStartDt?: string | null;
    publishEndDt?: string | null;
    sortOrdr?: number | null;
    viewCnt?: number | null;
    likeCnt?: number | null;
    commentCnt?: number | null;
    placeNm?: string | null;
    placeAddr?: string | null;
    lat?: string | null;
    lng?: string | null;
    useAt?: string | null;
    delAt?: string | null;
    delDt?: string | null;
    delBy?: string | null;
    createdDt?: string | null;
    createdBy?: string | null;
    updatedDt?: string | null;
    updatedBy?: string | null;
};

/**
 * TesttUpsertInput
 * - 업서트 API 파라미터 표준
 */
export type TesttUpsertInput = {
    diaryDt: string;
    content: string;
    grpCd?: string | null;
    ownerId?: Id | null;
};
