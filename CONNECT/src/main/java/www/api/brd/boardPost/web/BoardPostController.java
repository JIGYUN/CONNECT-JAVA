package www.api.brd.boardPost.web;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import www.api.brd.boardPost.service.BoardPostService;
import www.com.user.service.UserSessionManager;

import java.util.*;
import java.util.stream.Collectors;

@Controller
public class BoardPostController {

    @Autowired
    private BoardPostService boardPostService;

    /**
     * 게시판 목록 조회 (기존 유지)
     */
    @PostMapping("/api/brd/boardPost/selectBoardPostList")
    @ResponseBody
    public Map<String, Object> selectBoardPostList(@RequestBody HashMap<String, Object> map) {
        Map<String, Object> resultMap = new HashMap<>();
        List<Map<String, Object>> result = boardPostService.selectBoardPostList(map);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /**
     * 게시판 목록 조회 (페이징)
     * body: { page:1, size:20, ...검색필터 }
     * 응답: { msg, result:[...], page:{page,size,total,totalPages,hasNext,hasPrev} }
     */
    @PostMapping("/api/brd/boardPost/selectBoardPostListPaged")
    @ResponseBody
    public Map<String, Object> selectBoardPostListPaged(@RequestBody HashMap<String, Object> body) {
        Map<String, Object> paged = boardPostService.selectBoardPostListPaged(body);
        Map<String, Object> out = new HashMap<>();
        out.put("msg", "성공");
        out.put("result", paged.get("list"));
        out.put("page", paged.get("page"));
        return out;
    }

    /**
     * 게시판 단건 조회
     */
    @PostMapping("/api/brd/boardPost/selectBoardPostDetail")
    @ResponseBody
    public Map<String, Object> selectBoardPostDetail(@RequestBody HashMap<String, Object> map) {
        Map<String, Object> resultMap = new HashMap<>();
        Map<String, Object> result = boardPostService.selectBoardPostDetail(map);
        resultMap.put("msg", "성공");
        resultMap.put("result", result);
        return resultMap;
    }

    /**
     * 게시글 등록 (JSON 전송) - 기존 유지
     */
    @PostMapping("/api/brd/boardPost/insertBoardPost")
    @ResponseBody
    public Map<String, Object> insertBoardPost(@RequestBody HashMap<String, Object> map) {
        if (UserSessionManager.isUserLogined()) {
            map.put("createUser", UserSessionManager.getLoginUserVO().getEmail());
        }
        Map<String, Object> resultMap = new HashMap<>();
        boardPostService.insertBoardPost(map);
        resultMap.put("msg", "등록 성공");
        return resultMap;
    }

    /**
     * 게시글 수정 (JSON 전송) - 기존 유지
     */
    @PostMapping("/api/brd/boardPost/updateBoardPost")
    @ResponseBody
    public Map<String, Object> updateBoardPost(@RequestBody HashMap<String, Object> map) {
        if (UserSessionManager.isUserLogined()) {
            map.put("updateUser", UserSessionManager.getLoginUserVO().getEmail());
        }
        Map<String, Object> resultMap = new HashMap<>();
        boardPostService.updateBoardPost(map);
        resultMap.put("msg", "수정 성공");
        return resultMap;
    }

    /**
     * 게시글 삭제
     */
    @PostMapping("/api/brd/boardPost/deleteBoardPost")
    @ResponseBody
    public Map<String, Object> deleteBoardPost(@RequestBody HashMap<String, Object> map) {
        Map<String, Object> resultMap = new HashMap<>();
        boardPostService.deleteBoardPost(map);
        resultMap.put("msg", "삭제 성공");
        return resultMap;
    }

    /**
     * 게시글 개수 (기존)
     */
    @PostMapping("/api/brd/boardPost/selectBoardPostListCount")
    @ResponseBody
    public Map<String, Object> selectBoardPostListCount(@RequestBody HashMap<String, Object> map) {
        Map<String, Object> resultMap = new HashMap<>();
        int count = boardPostService.selectBoardPostListCount(map);
        resultMap.put("msg", "성공");
        resultMap.put("count", count);
        return resultMap;
    }

    /* ===================== 업로드 포함 등록/수정 (멀티파트) ===================== */

    /**
     * 게시글 등록 + 파일 업로드 (multipart/form-data)
     * form-data:
     *  - title, content, contentHtml(선택), fileGrpId(선택, 기존 그룹 재사용)
     *  - files (다중)
     */
    @PostMapping("/api/brd/boardPost/insertBoardPostWithFiles")
    @ResponseBody
    public Map<String, Object> insertBoardPostWithFiles(
            @RequestParam Map<String, String> form,
            @RequestParam(value = "files", required = false) List<MultipartFile> files
    ) {

        HashMap<String, Object> map = new HashMap<>(form);
        if (UserSessionManager.isUserLogined()) {
            map.put("createUser", UserSessionManager.getLoginUserVO().getEmail());
        }
        Long fileGrpId = null;
        if (form.get("fileGrpId") != null && !form.get("fileGrpId").trim().isEmpty()) {
            fileGrpId = Long.valueOf(form.get("fileGrpId"));
        }

        Map<String, Object> out = new HashMap<>();
        Long boardIdx = boardPostService.insertBoardPostWithFiles(map, files, fileGrpId);
        out.put("msg", "등록 성공");
        out.put("boardIdx", boardIdx);
        out.put("fileGrpId", map.get("fileGrpId")); // 서비스에서 최종 값 세팅
        return out;
    }

    /**
     * 게시글 수정 + 파일 업로드/선택 삭제 (multipart/form-data)
     * form-data:
     *  - boardIdx(필수), title, content, contentHtml(선택), fileGrpId(선택)
     *  - files (추가 업로드 다중)
     *  - deleteFileIds (동일 키로 여러 개 전송 가능)
     */
    @PostMapping("/api/brd/boardPost/updateBoardPostWithFiles")
    @ResponseBody
    public Map<String, Object> updateBoardPostWithFiles(
            @RequestParam Map<String, String> form,
            @RequestParam(value = "files", required = false) List<MultipartFile> files,
            @RequestParam(value = "deleteFileIds", required = false) String[] deleteFileIds
    ) {

        if (!form.containsKey("boardId")) {
            throw new IllegalArgumentException("boardId is required");
        }
        HashMap<String, Object> map = new HashMap<>(form);
        if (UserSessionManager.isUserLogined()) {
            map.put("updateUser", UserSessionManager.getLoginUserVO().getEmail());
        }

        Long fileGrpId = null;
        if (form.get("fileGrpId") != null && !form.get("fileGrpId").trim().isEmpty()) {
            fileGrpId = Long.valueOf(form.get("fileGrpId"));
        }

        List<Long> deleteIds = (deleteFileIds == null) ? Collections.emptyList() :
                Arrays.stream(deleteFileIds)
                        .filter(s -> s != null && !s.trim().isEmpty())
                        .map(Long::valueOf)
                        .collect(Collectors.toList());

        Map<String, Object> out = new HashMap<>();
        boardPostService.updateBoardPostWithFiles(map, files, fileGrpId, deleteIds);
        out.put("msg", "수정 성공");
        out.put("boardIdx", map.get("boardIdx"));
        out.put("fileGrpId", map.get("fileGrpId"));
        return out;
    }
}