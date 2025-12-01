// filepath: src/shared/prj/types.ts
import type { Id } from '@/shared/types/common';

/**
 * prjEntry
 * - DB 테이블 TB_PRJ 기반 자동생성
 * - PK: PRJ_ID
 */
export type prjEntry = {
    id?: Id | null;
    grpCd?: string | null;
    prjKey?: string | null;
    prjNm?: string | null;
    prjDesc?: string | null;
    statusCd?: string | null;
    colorCd?: string | null;
    createdDt?: string | null;
    createdBy?: string | null;
    updatedDt?: string | null;
    updatedBy?: string | null;
    useAt?: string | null;
};

/**
 * prjUpsertInput
 * - 업서트 API 파라미터 표준
 */
export type prjUpsertInput = {
    diaryDt: string;
    content: string;
    grpCd?: string | null;
    ownerId?: Id | null;
};
