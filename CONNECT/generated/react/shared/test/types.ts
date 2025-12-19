// filepath: src/shared/test/types.ts
import type { Id } from '@/shared/types/common';

/**
 * TestEntry
 * - DB 테이블 TB_TEST 기반 자동생성
 * - PK: TEST_IDX
 */
export type TestEntry = {
    id?: Id | null;
    title?: string | null;
    content?: number | null;
    createdBy?: string | null;
    createdDt?: string | null;
    updatedBy?: string | null;
    updatedDt?: string | null;
    useAt?: string | null;
    delYn?: string | null;
};

/**
 * TestUpsertInput
 * - 업서트 API 파라미터 표준
 */
export type TestUpsertInput = {
    diaryDt: string;
    content: string;
    grpCd?: string | null;
    ownerId?: Id | null;
};
