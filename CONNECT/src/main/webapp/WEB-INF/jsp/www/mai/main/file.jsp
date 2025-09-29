<%@ page contentType="text/html; charset=UTF-8" language="java" %>

<div class="card p-3">
  <div class="mb-2">
    <label>파일그룹ID(선택)</label>
    <input type="text" id="fileGrpId" class="form-control" placeholder="없으면 비워두면 새 그룹 생성"/>
  </div>

  <div class="mb-2">
    <input type="file" id="fileOne" />  
    <button type="button" class="btn btn-primary" onclick="uploadOne()">단건 업로드</button>
  </div>

  <div class="mb-2">
    <input type="file" id="fileMulti" multiple />
    <button type="button" class="btn btn-outline-primary" onclick="uploadMulti()">다건 업로드</button>
  </div>

  <div id="uploadResult" class="mt-3 small"></div>
  <ul id="fileList" class="mt-2"></ul>
</div>  

<script>
function uploadOne(){
  var fd = new FormData();
  var g = $("#fileGrpId").val();
  if (g) fd.append("fileGrpId", g);
  fd.append("file", $("#fileOne")[0].files[0]);
  $.ajax({
    url: "/api/com/file/uploadOne",
    type: "post",
    data: fd, processData: false, contentType: false,
    success: function(res){
      $("#uploadResult").text("그룹ID: " + res.fileGrpId + ", 업로드: " + res.files.length + "건");
      $("#fileGrpId").val(res.fileGrpId);
      renderList(res.files, res.fileGrpId);
    }, error: function(){ alert("업로드 실패"); }
  });
}
function uploadMulti(){
  var fd = new FormData();
  var g = $("#fileGrpId").val();
  if (g) fd.append("fileGrpId", g);
  var files = $("#fileMulti")[0].files;
  for (var i=0;i<files.length;i++){ fd.append("files", files[i]); }
  $.ajax({
    url: "/api/com/file/uploadMulti",
    type: "post",
    data: fd, processData: false, contentType: false,
    success: function(res){
      $("#uploadResult").text("그룹ID: " + res.fileGrpId + ", 업로드: " + res.files.length + "건");
      $("#fileGrpId").val(res.fileGrpId);
      renderList(res.files, res.fileGrpId);
    }, error: function(){ alert("업로드 실패"); }
  });
}
function renderList(files, gid){
  files.forEach(function(f){
    var li = $("<li/>").text(f.orgFileNm + " (" + f.fileSize + "B) ");
    var a = $("<a/>").attr("href","/api/com/file/download/"+f.fileId).text("다운로드");
    li.append(a);
    $("#fileList").append(li);
  });
}
</script>