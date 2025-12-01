// filepath: src/shared/issue/types.ts
import type { Id } from '@/shared/types/common';

/**
 * IssueEntry
 * - DB 테이블 TB_ISSUE 기반 자동생성
 * - PK: ISSUE_ID
 */
export type IssueEntry = {
    id?: Id | null;
    grpCd?: string | null;
    prjId?: number | null;
    issueNo?: number | null;
    issueKey?: string | null;
    issueTypeCd?: string | null;
    summary?: string | null;
    description?: string | null;
    priorityCd?: string | null;
    statusCd?: string | null;
    reporterId?: number | null;
    assigneeId?: number | null;
    parentIssueId?: number | null;
    startDt?: string | null;
    dueDt?: string | null;
    estimateMin?: number | null;
    spentMin?: number | null;
    orderInPrj?: number | null;
    createdDt?: string | null;
    createdBy?: string | null;
    updatedDt?: string | null;
    updatedBy?: string | null;
    useAt?: string | null;
};

/**
 * IssueUpsertInput
 * - 업서트 API 파라미터 표준
 */
export type IssueUpsertInput = {
    diaryDt: string;
    content: string;
    grpCd?: string | null;
    ownerId?: Id | null;
};
