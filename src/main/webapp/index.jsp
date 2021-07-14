<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<%
	String userID = null;
	// 세션로그인 아이디가 null이 아니면 userID에 값 등록
	if (session.getAttribute("userID") != null) {
		userID = (String) session.getAttribute("userID");
	}
%>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="css/bootstrap.css">
<link rel="stylesheet" href="css/custom.css">
<title>회원제 채팅서비스</title>

<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
<script src="js/bootstrap.js"></script>

<!--getUnread 처리 함수   -->
<script type="text/javascript">
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
			<a class="navbar-brand" href="index.jsp">회원제 채팅서비스 </a>
		</div>
		<div class="collapse navbar-collapse"
			id="bs-example-navbar-collapse-1">
			<ul class="nav navbar-nav">
				<li class="active"><a href="index.jsp">메인</a></li>
				<li ><a href="find.jsp">친구찾기</a></li>
				<li ><a href="box.jsp">메시지함<span id="unread" class="label label-info"></span></a></li>
			</ul>
			<!--  로그인이 안되었을 경우 로그인 및 회원가입 드롭메뉴 설정 -->
			<%
			if (userID == null) {
			%>
			<ul class="nav navbar-nav navbar-right">
				<li class="dropdown"><a href="#" class="dropdown-toggle"
					data-toggle="dropdown" role="button" aria-haspopup="true"
					aria-expanded="false">접속하기 <span class="caret"></span>
				</a>
					<ul class="dropdown-menu">
						<li><a href="login.jsp">로그인</a></li>
						<li><a href="join.jsp">회원가입</a></li>
					</ul>
				</li>
			</ul>
			<!--  로그인이 되었을 경우 : 회원관리 드롭메뉴만 뜨게 설정  -->
			<%
			} else {
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
	<% // 사용자가 정상 로그인 시
		if(userID != null) {
	%>
		
		<script type="text/javascript">
			// 기본적으로 메시지를 읽지않은 함수를 반복적으로 실행시키기
			$(document).ready(function(){
				getInfiniteUnread();
			});
		</script>
		<%	
			}
		%>
</body>
</html>
