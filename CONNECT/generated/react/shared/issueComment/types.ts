// filepath: src/shared/issueComment/types.ts
import type { Id } from '@/shared/types/common';

/**
 * issueCommentEntry
 * - DB 테이블 TB_ISSUE_COMMENT 기반 자동생성
 * - PK: COMMENT_ID
 */
export type issueCommentEntry = {
    id?: Id | null;
    grpCd?: string | null;
    issueId?: number | null;
    content?: string | null;
    writerId?: number | null;
    createdDt?: string | null;
    createdBy?: string | null;
    updatedDt?: string | null;
    updatedBy?: string | null;
    useAt?: string | null;
};

/**
 * issueCommentUpsertInput
 * - 업서트 API 파라미터 표준
 */
export type issueCommentUpsertInput = {
    diaryDt: string;
    content: string;
    grpCd?: string | null;
    ownerId?: Id | null;
};
