<%@page import="java.net.URLDecoder"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<%
	String userID = null;
	// 세션로그인 아이디가 null이 아니면 userID에 값 등록
	if (session.getAttribute("userID") != null) {
		userID = (String) session.getAttribute("userID");
	}
	
	String toID = null;
	if(request.getParameter("toID") != null){
		toID = (String) request.getParameter("toID");
	}
	// 로그인이 되어있지 않다면
	if (userID == null) {
		session.setAttribute("messageType", "오류메시지");
		session.setAttribute("messageContent", "현재 로그인이 되어있지 않습니다.");
		response.sendRedirect("index.jsp");
		return;
	}
	//대화 상대가 지정되어 있지 않다면 
	if (toID == null) {
		session.setAttribute("messageType", "오류메시지");
		session.setAttribute("messageContent", "대화 상대가 지정되지 않았습니다.");
		response.sendRedirect("index.jsp");
		return;
	}
	if(userID.equals(URLDecoder.decode(toID, "UTF-8"))){
		session.setAttribute("messageType", "오류메시지");
		session.setAttribute("messageContent", "자기자신에게 메시지를 보낼 수 없습니다.");
		response.sendRedirect("index.jsp");
		return;
	}
	%>
	
	
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="css/bootstrap.css">
<link rel="stylesheet" href="css/custom.css">
<title>회원제 채팅서비스</title>

<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
<script src="js/bootstrap.js"></script>
<script type="text/javascript">
	function autoClosingAlert(selector, delay){
		var alert = $(selector).alert();
		alert.show();
		window.setTimeout(function() { alert.hide() }, delay);
	}
	
	// 전송 버튼 시 fromID는 자기자신인 userID가 된다.
	function submitFunction(){
		var fromID = '<%= userID %>';
		var toID = '<%= toID %>';
		var chatContent = $('#chatContent').val();
		
		$.ajax({
			type: "POST",
			url: "./chatSubmitServlet",
			data: {
				fromID: encodeURIComponent(fromID),
				toID: encodeURIComponent(toID),
				chatContent: encodeURIComponent(chatContent),
				
			},
			success: function(result){
				//전송 성공 시 성공alert
				if(result == 1) {
					autoClosingAlert('#successMessage', 2000);
				} else if (result == 0) {
					//전송 오류 시 오류 alert
					autoClosingAlert('#dangerMessage', 2000);
				} else {
					//전송 실패 시 실패 alert
					autoClosingAlert('#warningMessage', 2000);
				}
			}
		});
		// 메시지를 보냈으니 content의 값을 비워준다.
		$('#chatContent').val('');
	}
	// 가장 마지막으로 채팅한 ID
	var lastID = 0;
	function chatListFunction(type){
		var fromID = '<%= userID %>';
		var toID = '<%= toID %>';
		$.ajax({
			type: "POST",
			url: "./chatListServlet",
			data: {
				fromID: encodeURIComponent(fromID),
				toID: encodeURIComponent(toID),
				listType: type
				
			},
			success: function(data){
				if(data == "")
					return;
				var parsed = JSON.parse(data);
				var result = parsed.result;
				for(var i = 0; i < result.length; i++){
					if(result[i][0].value == fromID){
						result[i][0].value = '나';
					}
					addChat(result[i][0].value, result[i][2].value, result[i][3].value);
				}
				// 가장 마지막으로 전달 받은 ID가 저장이 된다.
				lastID = Number(parsed.last);
			}
		});
		
	}
	// 채팅을 보낸사람, 내용, 시간 
	// 채팅 메시지 형태
	function addChat(chatName, chatContent, chatTime) {
		$('#chatList').append('<div class="row">' +
				'<div class="col-lg-12">' +
				'<div class="media">' +
				'<a class="pull-left" href="#">' +
				'<img class="media-object img-circle" style="width: 30px; height: 30px;" src="images/icon.png" alt="">' +
				'</a>'+
				'<div class="media-body">' +
				'<h4 class="media-heading">' +
				chatName +
				'<span class="small pull-right">' +
				chatTime +
				'</span>' +
				'</h4>' +
				'<p>' +
				chatContent + 
				'</p>' +
				'</div>' +
				'</div>' +
				'</div>' +
				'</div>' +
				'<hr>');
		$('#chatList').scrollTop($('#chatList')[0].scrollHeight); // 스크롤을 맨 아래로 두기
	}
	// 몇 초 간격으로 새로운 메시지가 온지 가져오는 것
	function getInfiniteChat(){
		setInterval(function(){
			chatListFunction(lastID);
		}, 3000);
	}
	
	
	
	function getUnread(){
		$.ajax({
			type : "POST",
			url : "./chatUnread",
			data : {
				userID : encodeURIComponent('<%= userID %>'),
				
			},
			success: function(result){
				//  0을 받으면 에러, 1이상을 받으면 정상처리
				if(result >= 1){
					showUnread(result);
				} else {
					// 0이 입력받을 때 공백 처리
					showUnread('');
				}
			}
		});
	}
	// 반복적으로 서버한테 일정 주기 마다 자신이 읽지 않은 메시지 갯수를 요청하는 함수
	function getInfiniteUnread(){
		setInterval(function(){		
			getUnread();			
		}, 1000);
	}
	// unread라는 id값을 가진 원소 내부 값을 result로 담아주기.
	function showUnread(result){
		$('#unread').html(result);
	}
</script>

</head>
<body>
	
	<nav class="navbar navbar-default">
		<div class="navbar-header">
			<button type="button" class="navbar-toggle collapsed"
				data-toggle="collapse" data-target="#bs-example-navbar-collapse-1"
				aria-expanded="false">
				<span class="icon-bar"></span> <span class="icon-bar"></span> <span
					class="icon-bar"></span>
			</button>
			<a class="navbar-brand" href="index.jsp"> 채팅서비스 </a>
		</div>
		<div class="collapse navbar-collapse"
			id="bs-example-navbar-collapse-1">
			<ul class="nav navbar-nav">
				<li><a href="index.jsp">메인</a></li>
				<li><a href="find.jsp">친구찾기</a></li>
				<li ><a href="box.jsp">메시지함<span id="unread" class="label label-info"></span></a></li>
			</ul>
			<%
				if(userID != null){
			%>

			<ul class="nav navbar-nav navbar-right">
				<li class="dropdown">
					<a href="#" class="dropdown-toggle"
					data-toggle="dropdown" role="button" aria-haspopup="true"
					aria-expanded="false">회원관리 <span class="caret"></span>
					</a>
					<ul class="dropdown-menu">
						<li><a href="logoutAction.jsp">로그아웃</a></li>
					</ul>
				</li>
			</ul>
			<%
			}
			%>
		</div>
	</nav>
	<div class="container bootstrap snippet">
		<div class="row">
			<div class="col-xs-12">
				<div class="portlet portlet-default">

					<div class="portlet-heading">
						<div class="portlet-title">
							<h4>
								<i class="fa fa-circle text-green"></i>실시간 채팅창</h4>
						</div>
						<div class="clearfix"></div>
					</div>
					<div id="chat" class="panel-collapse collpase in">
						<div id="chatList" class="portlet-body chat-widget" style="overflow-y: auto; width: auto; height: 600px;">
						</div>
						<div class="portlet-footer">
							<div class="row" style="height: 90px;">
								<div class="form-group col-xs-10">
									<textarea style="heigh: 80px;" id="chatContent"
										class="form-control" placeholder="메시지를 입력하세요." maxlength="100"></textarea>
								</div>
								<div class="form-group col-xs-2">
									<button type="button" class="btn btn-default pull-right"
										onclick="submitFunction();">전송</button>
									<div class="clearfix"></div>
							</div>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
	<div class="alert alert-success" id="successMessage"
		style="display: none;">
		<strong>메시지 전송에 성공했습니다.</strong>
	</div>
	<div class="alert alert-danger" id="dangerMessage"
		style="display: none;">
		<strong>이름과 내용을 모두 입력해주세요.</strong>
	</div>
	<div class="alert alert-warning" id="warningMessage"
		style="display: none;">
		<strong>데이터베이스 오류 발생했습니다. </strong>
	</div>

	<%
	String messageContent = null;
	if (session.getAttribute("messageContent") != null) {
		messageContent = (String) session.getAttribute("messageContent");
	}

	String messageType = null;
	if (session.getAttribute("messageType") != null) {
		messageType = (String) session.getAttribute("messageType");
	}
	if (messageContent != null) {
	%>
	<div class="modal fade" id="messageModal" tabindex="-1" role="dialog"
		aria-hidden="true">
		<div class="vertical-alignment-helper">
			<div class="modal-dialog vertical-align-center">
				<div
					class="modal-content <%if (messageType.equals("오류 메시지"))
	out.println("panel-warning");
else
	out.println("panel-success");%>">
					<div class="modal-header panel-heading">
						<button type="button" class="close" data-dismiss="modal">
							<span aria-hidden="true">&times</span> <span class="sr-only">Close</span>

						</button>
						<h4 class="modal-title">
							<%=messageType%>
						</h4>
					</div>
					<div class="modal-body">
						<%=messageContent%>
					</div>
					<div class="modal-footer">
						<button type="button" class="btn btn-primary" data-dismiss="modal">확인</button>

					</div>
				</div>
			</div>
		</div>
	</div>
	<script>
		$('#messageModal').modal("show");
		
	</script>
	<%
	session.removeAttribute("messageContent");
	session.removeAttribute("messageType");
	}
	%>
	<script type="text/javascript">
	$(document).ready(function(){
		getUnread();
		chatListFunction('0');
		getInfiniteChat();
		getInfiniteUnread();
	});
	</script>
</body>
</html>
