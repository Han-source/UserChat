package chat;

import java.io.IOException;
import java.net.URLDecoder;
import java.util.ArrayList;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet implementation class ChatUnreadServlet
 */
@WebServlet("/ChatBoxServlet")
public class ChatBoxServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
  
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		request.setCharacterEncoding("UTF-8");
		response.setContentType("text/html; charset=UTF-8");
		// 특정 사용자(userID) 아이디 값을 매개변수로 받는다. 
		String userID = request.getParameter("userID");
		// 넘어온 사용자 아이디 값이 존재하지 않는다면
		if(userID == null || userID.equals("")) {
			// 0이라는 값을 출력하여 클라이언트에게 오류가 발생하였다는 것을 알려준다.
			response.getWriter().write("");
		} else {
			  try {
				  	// 정상적으로 값이 들어왔다면 사용자 아이디를 utf-8 형태로 디코딩을 한다.
					userID = URLDecoder.decode(userID,"UTF-8");
					//userID를 인자로 받아 특정 사용자의 메시지함을 출력
					response.getWriter().write(getBox(userID));
			  } catch(Exception e) {
				 // 공백으로 예외 처리
				  response.getWriter().write("");
			  }
			
			
		}
	}
	
	// 메시지의 리스트의 결과를 바로 출력
	public String getBox(String userID) {
		StringBuffer result = new StringBuffer("");
		// json 형태
		result.append("{\"result\":[");
		ChatDAO chatDAO = new ChatDAO();
		ArrayList<ChatDTO> chatList = chatDAO.getBox(userID);
		if(chatList.size() == 0)
			return "";
		for(int i = 0; i < chatList.size(); i++) {
			result.append("[{\"value\": \"" + chatList.get(i).getFromID() + "\"},");
			result.append("{\"value\": \"" + chatList.get(i).getToID() + "\"},");
			result.append("{\"value\": \"" + chatList.get(i).getChatContent() + "\"},");
			result.append("{\"value\": \"" + chatList.get(i).getChatTime() + "\"}]");
			//마지막 원소가 아니라면 다음 원소가 있다는 것을 알려준다.
			if(i != chatList.size() -1)
				result.append(",");
		}
		result.append("], \"last\":\"" + chatList.get(chatList.size() -1).getChatID() + "\"}");
		return result.toString();
	}
}
