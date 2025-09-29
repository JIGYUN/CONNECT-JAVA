///////////////////////////////////////////////////////
// 계층형 node를 html select tag 생성

/**
 * 계층형 Node를 html select 태그로 생성해준다.
 * 
 * @param beginNodeIdx : 그룹(시작) nodeIdx (필수)
 * @param appendTargetElId : 생성된 select tag를 넣을 html element id (필수)
 * @param setValueTargetElId : 선택한 nodeIdx값을 넣어 줄 input element id  (필수)
 * @param endNodeIdx : 선택한 마지막 depth의 nodeIdx. 빈값입력시 그룹 select만 생성된다. (옵션)
 * @param isReadOnly : true = 생성된 select tag를 읽기 전용으로 표시할때, false = 선택할수 있게. 기본값 false (옵션)
 */
function initNodeSelectbox(beginNodeIdx, appendTargetElId, 
						setValueTargetElId, endNodeIdx, isReadOnly){
	
	beginNodeIdx 		= beginNodeIdx || '';
	endNodeIdx 	 		= endNodeIdx || '';
	appendTargetElId 	= appendTargetElId || '';
	setValueTargetElId 	= setValueTargetElId || '';
	isReadOnly 	 		= isReadOnly || false;
	
	// 그룹 nodeIdx가 있을때만.
	if(beginNodeIdx != ''){
		
		// 마지막 depth nodeIdx가 있을때만.
		if(endNodeIdx != ''){
			
			// endNodeIdx의 node 조회로 부모의 path를 구하기 위한 ajax call
			$.ajax({
				url :  '/com/node/getNode',
				data : {
					idx : endNodeIdx
				},
				async : false,
				success : function(data){
					
					if(data != null && data != ''){
						
						var jsonData = $.parseJSON(data),
							pathArr = [];
						
						if(jsonData != null){
							pathArr = jsonData.path.split("/");
						}
						
						if(pathArr != null && pathArr.length > 1){
							
							var beginIndex = -1;
							
							// 현재 function beginNodeIdx인자로
							// path의 index를 찾는다.
							for(var i=0; i < pathArr.length; i++){
								if(pathArr[i] == beginNodeIdx){
									beginIndex = i;
								}						
							}
							
							if(beginIndex != -1){
								
								// 위에 찾은 index로 node의 부모 node부터 그에해당하는 모든 childNodeList를
								// 구하여 select 태그를 생성한다.
								$.ajax({
									url :  '/com/node/getNodeWithAllChild',
									data : {
										idx : beginNodeIdx
									},
									async : false,
									success : function(data){
										
										if(data != null && data != ''){
											
											var beginNode = $.parseJSON(data);
											
											for(; beginIndex < pathArr.length; beginIndex++){
												
												var pIdx = pathArr[beginIndex],
													childIdx = '';
											
												if(pathArr.length > beginIndex + 1){
													
													childIdx = pathArr[beginIndex + 1];
												}
												
												var childNodeList = getNodeChildListFromNodeObject(beginNode, pIdx);
												
												if($.isArray(childNodeList)){
													
													var selTag = nodeSelectboxTagGenerator(childNodeList, childIdx,
															appendTargetElId, setValueTargetElId);
													
													if(selTag != ''){
														
														$('#'+appendTargetElId).append(selTag);
														
													}
												}
												
											}
										}
									}	
								});
							}
						}
					}
				}
			});
		}
		// 그룹 nodeIdx일때..
		else {
			
			nodeSelectboxGenerator(beginNodeIdx, '', 
					appendTargetElId, setValueTargetElId);
			
		}
		
		// hidden input field에 select값을 세팅
		if(setValueTargetElId != ''){
			
			var genSelectList = $('#' + appendTargetElId).children();
			
			// select html tag가 생성되는 target영역의 select중에 제일 하위의 빈값이 아닌 값이 있는걸
			// hidden input value에 값을 세팅한다.
			for(var i=genSelectList.length; i >= 0; i--){
				
				var el = genSelectList[i],
					elVal = $(el).val();
				
				elVal = elVal || '';
				
				if(elVal != ''){
					
					$('#' + setValueTargetElId).val(elVal);
					
					break;
				}
			}
		}
		
		// 읽기전용 옵션이 true면 select tag를 readonly로 설정한다.
		if(isReadOnly){
			
			$('#'+appendTargetElId).find(":input").each(function(idx, obj){
				
				var nodeName = obj.nodeName.toLowerCase();
				
				if("select" == nodeName){
					
					$(obj).attr("disabled", "disabled");
				}
			});
		}
	}
}

/**
 * 계층형 node object에서 검색하여 parentNodeIdx에 해당하는 childList를 돌려준다.
 *
 * @param node : 검색할 node 
 * @param parentNodeIdx : 부모 nodeIdx 키값
 */
function getNodeChildListFromNodeObject(node, parentNodeIdx){
	
	var childList = node.childList;
	
	if (parentNodeIdx == node.idx){
		return childList;
	}
	
	if($.isArray(childList)){
		
		for(var i=0; i<childList.length; i++){
			
			var subNodeChildList = getNodeChildListFromNodeObject(childList[i], parentNodeIdx);
			
			if(subNodeChildList != null){
				return subNodeChildList;
			}
		}
	}
	
	return null;
}
	
/**
 * 계층형 node의 html select tag 생성하여 target 영역에 넣어준다.
 */
function nodeSelectboxGenerator(parentNodeIdx, selectedNodeIdx, appendTargetElId, setValueTargetElId){	
	
	parentNodeIdx 		= parentNodeIdx || '';
	selectedNodeIdx 	= selectedNodeIdx || '';
	appendTargetElId 	= appendTargetElId || '';
	setValueTargetElId 	= setValueTargetElId || '';
	
	var nodeUrl =  '/com/node/getNode';
	
	if(parentNodeIdx != ''){
		$.ajax({
			url : nodeUrl,
			data : {
				parent : parentNodeIdx
			},
			async : false,
			success : function(data){
				
				if(data != null && data != ''){
					var jsonData = $.parseJSON(data);
					
					var selTag = nodeSelectboxTagGenerator(jsonData, selectedNodeIdx, 
							appendTargetElId, setValueTargetElId);
					
					if(selTag != ''){
						
						$('#' + appendTargetElId).append(selTag);	
					} 
				}
			}
		});
	}
}

/**
 * 계층형 node의 html select tag 생성하여 문자열로 리턴한다.
 */
function nodeSelectboxTagGenerator(nodeList, selectedNodeIdx, appendTargetElId, setValueTargetElId){
	
	selectedNodeIdx 	= selectedNodeIdx || '';
	appendTargetElId 	= appendTargetElId || '';
	setValueTargetElId 	= setValueTargetElId || '';
	
	var selTag = "";
	
	if(nodeList.length > 0){
		
		selTag = '<select onchange="removeChildNodeSelectbox(this);'
				+' nodeSelectboxGenerator('
				+ '$(this).val(),'
				+ ' null,'
				+ ' \'' + appendTargetElId + '\','
				+ ' \'' + setValueTargetElId + '\''
				+');';
				
		if(setValueTargetElId != ''){
			
			selTag += ' $(\'#'+ setValueTargetElId +'\').val($(this).val());';
		}		
			selTag += '">'
				+ '	<option value="">전체</option>';
		
		for(var i=0; i < nodeList.length; i++){
			var node = nodeList[i];
			
			// 사용안함 node는 제외
			if(node.useYn == 'Y'){
				selTag += '	<option value="'+ node.idx +'"';
				
				if(selectedNodeIdx == node.idx){
					
					selTag += ' selected="selected"';
				}
				
				selTag += '>'
						+ node.name
						+ ' </option>';
			};						
		}
				
		selTag += '</select>';
	}
	
	return selTag;
}

function removeChildNodeSelectbox(obj){
	
	$(obj).nextAll().each(function(idx, obj){
		
		var nodeName = obj.nodeName.toLowerCase();
		
		if("select" == nodeName){
			
			$(obj).remove();
		}
	});
}

/**
* 외부 연동 코드 selectbox 생성기
*
* @param grpCode : 그룹 코드 값 (필수)
* @param grpCodeType : 그룹 코드타입 값 (필수)
* @param targetCodeType : 조회 대상 코드타입 값  (필수)
* @param appendTargetElId : 생성된 select tag를 넣을 html element id (필수)
* @param setValueTargetElId : 선택한 코드 값을 넣어 줄 input element id  (옵션)
* @param selectedCode : 저장된 코드 값 (옵션)
* @param onchangeFn : selectbox onchange function (옵션)
*/
function initExtCodeSelectbox(grpCode, grpCodeType, targetCodeType, 
			appendTargetElId, setValueTargetElId, selectedCode, onchangeFn){
	
	grpCode 			= grpCode || '';
	grpCodeType 		= grpCodeType || '';
	targetCodeType 		= targetCodeType || '';
	setValueTargetElId 	= setValueTargetElId || '';
	appendTargetElId 	= appendTargetElId || '';
	selectedCode 	 	= selectedCode || '';
	onchangeFn 	 		= onchangeFn || '';

	$.ajax({
		url :  '/code/getCodeAjax',
		data : {
			groupCode 		: grpCode,
			groupCodeType 	: grpCodeType,
			targetCodeType 	: targetCodeType
		},
		async : false,
		dataType : 'json',
		success : function(data){
			
			if(data != null){
				var tag = '<select ';
				
				tag += 'onchange="';
				tag += ' $(\'#'+ setValueTargetElId +'\').val($(this).val());';
				
				if(onchangeFn != ''){
					
					onchangeFn = onchangeFn.replace(/"/gi, "'");
					
					tag += onchangeFn;
				}
				
				tag += '" >';
				
				tag += '<option value=""> ';
				tag += '--선택하세요--';
				tag += '</option>';
				for(var idx in data){
					var code = data[idx];
					
					tag += '<option value="'+code.code+'" ';
					
					if(selectedCode != '' && 
							code.code == selectedCode){
						tag += 'selected="selected"';
					}
					
					tag += ' >';
					tag += code.codeName;
					tag += '</option>';
				}
				
				tag += '</select>';
				
				if(appendTargetElId != ''){
					$('#' + appendTargetElId).append(tag);
					//$('#' + appendTargetElId).html(tag);
					//$('#' + appendTargetElId)[0].innerHTML = tag
				}
			}
		}
	});
}