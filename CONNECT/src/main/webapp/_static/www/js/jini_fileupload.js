/*
* 파일 업로드 validate init
*/
function _initAsyncFileUploadValidate(initObjParam){
	(function (initObj) {
		
		var fileExt = initObj.fileExt || '',
			fileMaxSize = initObj.fileMaxSize || 0,
			extParam = [];	
		
		//전체 공백문자열 제거
		fileExt = fileExt.replace(/ /g, '');
		
		//확장자 체크
		if(fileExt.length > 0){
			extParam.push({
				name : 'allowUploadFileExtensions',
				value : fileExt
			});
		}
		
		//업로드 최대허용 용량체크
		if(fileMaxSize > 0){
			extParam.push({
				name : 'allowUploadFileMaxSize',
				value : fileMaxSize
			});
		}
		
		$('#' + initObj.elementId).on('change', function(){
			
			//support FileReader object
			if(this.files){
				
				_fileValidate({
					fileInput : this,
	        		allowFileSize : fileMaxSize,
	        		allowFileExt : fileExt
	        	});
			}
		});
	})(initObjParam);
}

/*
* 첨부파일 삭제
*/
function _removeAsyncFile(obj, cfIdx, cfKey){
	
	cfIdx = cfIdx || '';
	cfKey = cfKey || '';
	
	if(confirm('첨부파일을 삭제하시겠습니까?')){
		
		if(cfIdx != '' && cfKey != ''){
			//업로드 그룹 영역에 삭제 파라미터 값들을 추가한다.
			$(obj).closest('.fileUploadGroupContainer')
			.append('<input type="hidden" name="'+ _DELETE_FILE_IDX_PARAM_NAME +'" value="'+ cfIdx +'"/>'
					+ '<input type="hidden" name="'+ _DELETE_FILE_KEY_PARAM_NAME +'" value="'+ cfKey +'"/>');
		}
		
		var downloadContainer = $(obj).closest('.downloadAsyncFileContainer'),
			uploadContainer = downloadContainer.siblings('.uploadAsyncFileContainer');

		uploadContainer.show();
		downloadContainer.remove();
	}
}

/*
* 파일 검증 fn
*
* @return 파일 검증 성공 시 true 그 외 false
*/
function _fileValidate(data){
	var isValid = true;
	
	var exType = '',
		errMsg = '파일 업로드 중 에러가 발생하였습니다.',
		inputFileObj = data.fileInput.files[0],
		inputFileName = inputFileObj.name, 
		inputFileExt = '',
		inputFileSize = 0,
		allowFileSize = data.allowFileSize,
		allowFileExt = data.allowFileExt;
	
	//업로드할 파일 확장자
	if(inputFileName.indexOf('.') != -1){
		inputFileExt = inputFileName.substring(inputFileName.lastIndexOf('.') + 1);
	}
	
	inputFileSize = inputFileObj.size;
	
	//확장자 체크
	if(allowFileExt.toLowerCase().indexOf(inputFileExt.toLowerCase()) == -1){
		exType = _FILEUPLOAD_EX_TYPE_FILE_ALLOW_EXTENSION;
	}
	
	//support script
	if(inputFileSize && !isNaN(inputFileSize)){
		
		if(inputFileSize > allowFileSize){
			exType = _FILEUPLOAD_EX_TYPE_FILE_SIZE_EXCEED;
		}else if(inputFileSize == 0){
			exType = _FILEUPLOAD_EX_TYPE_FILE_EMPTY;
		}
	}

	//업로드 허용 파일 사이즈 초과 타입
	if(exType == _FILEUPLOAD_EX_TYPE_FILE_SIZE_EXCEED){
		errMsg = inputFileName + ' 파일은 허용 업로드 용량을 초과하였습니다.\n'
				+ '허용용량 : ' + filesize(allowFileSize) + ', 선택한 파일용량 :' + filesize(inputFileSize);
		
		isValid = false;
	}
	//업로드 허용 확장자 타입
	else if(exType == _FILEUPLOAD_EX_TYPE_FILE_ALLOW_EXTENSION){
		errMsg = inputFileExt + ' 확장자는 업로드 할 수 없습니다.\n'
				+ '허용확장자 : ' + allowFileExt;
		
		isValid = false;
	}
	//빈파일 업로드
	else if(exType == _FILEUPLOAD_EX_TYPE_FILE_EMPTY){
		errMsg = '파일용량이 0인 파일은 업로드 할 수 없습니다.';
		isValid = false;
	}
	
	if(!isValid){
		alert(errMsg);

		var fileObj = $(data.fileInput);
		fileObj.replaceWith(fileObj.clone(true));
	}
	
	return isValid;
}