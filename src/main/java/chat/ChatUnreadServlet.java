package chat;

import java.io.IOException;
import java.net.URLDecoder;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet implementation class ChatUnreadServlet
 */
@WebServlet("/ChatUnreadServlet")
public class ChatUnreadServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
  
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		request.setCharacterEncoding("UTF-8");
		response.setContentType("text/html; charset=UTF-8");
		// 특정 사용자(userID) 아이디 값을 매개변수로 받는다. 
		String userID = request.getParameter("userID");
		// 넘어온 사용자 아이디 값이 존재하지 않는다면
		if(userID == null || userID.equals("")) {
			// 0이라는 값을 출력하여 클라이언트에게 오류가 발생하였다는 것을 알려준다.
			response.getWriter().write("0");
		} else {
			// 정상적으로 값이 들어왔다면 사용자 아이디를 utf-8 형태로 디코딩을 한다.
			userID = URLDecoder.decode(userID,"UTF-8");
			//ChatDAO에 정의된 AllUnreadChat에 userID를 문자열로 바꾸어서 출력한다.
			// 즉 읽지 않은 채팅 수를 클라이언트에게 출력해주는 부분.
			response.getWriter().write(new ChatDAO().getAllUnreadChat(userID) + "");
		}
	}

}
