package www.api.brd.boardPost.service;

import java.util.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import www.com.util.CommonDao;
import www.api.com.file.service.FileService;
import www.com.pag.PagingHelper;

@Service
public class BoardPostService {

    private final String namespace = "www.api.brd.boardPost.BoardPost";

    @Autowired
    private CommonDao dao;

    @Autowired
    private FileService fileService;

    /**
     * 목록 조회 (기존 비페이징)
     */
    public List<Map<String, Object>> selectBoardPostList(Map<String, Object> paramMap) {
        return dao.list(namespace + ".selectBoardPostList", paramMap);
    }

    /**
     * 목록 수 조회 (기존)
     */
    public int selectBoardPostListCount(Map<String, Object> paramMap) {
        return dao.selectOneInt(namespace + ".selectBoardPostListCount", paramMap);
    }

    /**
     * 목록 조회 (페이징) - PagingHelper 표준 포맷 반환
     * 입력: paramMap 내 page/size(+ 검색필터)
     * 출력: { list, page:{page,size,total,totalPages,hasNext,hasPrev} }
     */
    public Map<String, Object> selectBoardPostListPaged(Map<String, Object> paramMap) {
        return PagingHelper.run(
            dao,
            namespace + ".selectBoardPostList",         // limit/offset 사용 목록 쿼리
            namespace + ".selectBoardPostListCount",    // INT 단일 컬럼 카운트(이미 selectOneInt 사용 중)
            paramMap
        );
    }

    /**
     * 단건 조회 (기존)
     */
    public Map<String, Object> selectBoardPostDetail(Map<String, Object> paramMap) {
        return dao.selectOne(namespace + ".selectBoardPostDetail", paramMap);
    }

    /**
     * 등록 (JSON, 기존)
     */
    @Transactional
    public void insertBoardPost(Map<String, Object> paramMap) {
        dao.insert(namespace + ".insertBoardPost", paramMap);
    }

    /**
     * 수정 (JSON, 기존)
     */
    @Transactional
    public void updateBoardPost(Map<String, Object> paramMap) {
        dao.update(namespace + ".updateBoardPost", paramMap);
    }

    /**
     * 삭제 (기존)
     */
    @Transactional
    public void deleteBoardPost(Map<String, Object> paramMap) {
        dao.delete(namespace + ".deleteBoardPost", paramMap);
    }

    /* ===================== 업로드 포함 등록/수정 (멀티파트 오케스트레이션) ===================== */

    /**
     * 등록 + 파일업로드
     */
    @Transactional
    public Long insertBoardPostWithFiles(Map<String, Object> paramMap,
                                         List<MultipartFile> files,
                                         Long fileGrpId) {
        if (files != null && !files.isEmpty()) {
            Map<String, Object> res = fileService.upload(fileGrpId, null, "BOARD 첨부", files);
            fileGrpId = ((Number) res.get("fileGrpId")).longValue();
        }
        paramMap.put("fileGrpId", fileGrpId);

        dao.insert(namespace + ".insertBoardPost", paramMap);
        Object pk = paramMap.get("boardIdx"); // 매퍼 useGeneratedKeys 시 주입
        return (pk == null) ? null : ((Number) pk).longValue();
    }

    /**
     * 수정 + 파일추가/선택삭제
     */
    @Transactional
    public void updateBoardPostWithFiles(Map<String, Object> paramMap,
                                         List<MultipartFile> files,
                                         Long fileGrpId,
                                         List<Long> deleteFileIds) {
        if (deleteFileIds != null && !deleteFileIds.isEmpty()) {
            for (Long fid : deleteFileIds) {
                dao.update("www.api.com.file.File.softDeleteFile", Collections.singletonMap("fileId", fid));
            }
        }

        if (files != null && !files.isEmpty()) {
            Map<String, Object> res = fileService.upload(fileGrpId, null, "BOARD 첨부", files);
            fileGrpId = ((Number) res.get("fileGrpId")).longValue();
        }

        paramMap.put("fileGrpId", fileGrpId);
        dao.update(namespace + ".updateBoardPost", paramMap);
    }
}