package chat;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;


public class ChatDAO {
	DataSource dataSource;
	// 디비 연결
	public ChatDAO() {
		try {
			InitialContext initContext = new InitialContext();
			Context envContext = (Context) initContext.lookup("java:/comp/env");
			dataSource = (DataSource) envContext.lookup("jdbc/UserChat");
		}catch(Exception e) {
			e.printStackTrace();
		}
	}
	
	public ArrayList<ChatDTO> getChatListByID(String fromID, String toID, String chatID){
		ArrayList<ChatDTO> chatList = null;
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		
		String SQL = "select * from chat where ((fromID = ? and toID = ?) or (fromID = ? and toID = ?)) and chatID > ? order by chatTime";
		try {
			conn = dataSource.getConnection();
			pstmt = conn.prepareStatement(SQL);
			pstmt.setString(1, fromID);
			pstmt.setString(2, toID);
			pstmt.setString(3, toID);
			pstmt.setString(4, fromID);
			pstmt.setInt(5, Integer.parseInt(chatID));
			rs = pstmt.executeQuery();
			chatList = new ArrayList<ChatDTO>();
			while(rs.next()) {
				ChatDTO chat = new ChatDTO();
				chat.setChatID(rs.getInt("chatID"));
				chat.setFromID(rs.getString("fromID").replaceAll(" ", "&nbsp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll("\n", "<br>"));
				chat.setToID(rs.getString("toID").replaceAll(" ", "&nbsp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll("\n", "<br>"));
				chat.setChatContent(rs.getString("chatContent").replaceAll(" ", "&nbsp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll("\n", "<br>"));
				int chatTime = Integer.parseInt(rs.getString("chatTime").substring(11, 13));
				String timeType="오전";
				if (chatTime > 12) {
					timeType = "오후";
					chatTime -=12;
					
				}
				chat.setChatTime(rs.getString("chatTime").substring(0, 11) + " " + timeType + " " + chatTime + ":" + rs.getString("chatTime").substring(14, 16) + " ");
				chatList.add(chat);
			}
		} catch(Exception e) {
			e.printStackTrace();
		} finally {
			try {
				if(rs !=null) rs.close();
				if(pstmt !=null) pstmt.close();
				if(conn !=null) conn.close();
				
			}catch (Exception e) {
				e.printStackTrace();
			}
		}
		return chatList; //리스트 반환
	}
	
	public ArrayList<ChatDTO> getChatListByRecent(String fromID, String toID, int number){
		ArrayList<ChatDTO> chatList = null;
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		
		String SQL = "select * from chat where ((fromID = ? and toID = ?) or (fromID = ? and toID = ?)) and chatID > (select max(chatID) - ? from chat where (fromID = ? AND toID = ?) or (fromID = ? and toID = ?)) order by chatTime";
		try {
			conn = dataSource.getConnection();
			pstmt = conn.prepareStatement(SQL);
			pstmt.setString(1, fromID);
			pstmt.setString(2, toID);
			pstmt.setString(3, toID);
			pstmt.setString(4, fromID);
			pstmt.setInt(5, number);
			pstmt.setString(6, fromID);
			pstmt.setString(7, toID);
			pstmt.setString(8, toID);
			pstmt.setString(9, fromID);
			rs = pstmt.executeQuery();
			chatList = new ArrayList<ChatDTO>();
			while(rs.next()) {
				ChatDTO chat = new ChatDTO();
				chat.setChatID(rs.getInt("chatID"));
				chat.setFromID(rs.getString("fromID").replaceAll(" ", "&nbsp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll("\n", "<br>"));
				chat.setToID(rs.getString("toID").replaceAll(" ", "&nbsp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll("\n", "<br>"));
				chat.setChatContent(rs.getString("chatContent").replaceAll(" ", "&nbsp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll("\n", "<br>"));
				int chatTime = Integer.parseInt(rs.getString("chatTime").substring(11, 13));
				String timeType="오전";
				if (chatTime > 12) {
					timeType = "오후";
					chatTime -=12;
					
				}
				chat.setChatTime(rs.getString("chatTime").substring(0, 11) + " " + timeType + " " + chatTime + ":" + rs.getString("chatTime").substring(14, 16) + " ");
				chatList.add(chat);
			}
		} catch(Exception e) {
			e.printStackTrace();
		} finally {
			try {
				if(rs !=null) rs.close();
				if(pstmt !=null) pstmt.close();
				if(conn !=null) conn.close();
				
			}catch (Exception e) {
				e.printStackTrace();
			}
		}
		return chatList; //리스트 반환
	}
	
	
	// 메세지함을 만드는 controller
	public ArrayList<ChatDTO> getBox(String userID){
		ArrayList<ChatDTO> chatList = null;
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		
		// A라는 사용자가 B,C,D 라는 사용자와 대화를 했을 때 B,C,D와 가장 최근에 주고받은 메시지를 출력하게
		// 쿼리문 짜기.
		String SQL = "select * from chat where chatID in (select MAX(chatID) from chat where toID = ?"
				+ "or fromID = ? group by fromID, toID)";
		try {
			conn = dataSource.getConnection();
			pstmt = conn.prepareStatement(SQL);
			pstmt.setString(1, userID);
			pstmt.setString(2, userID);

			rs = pstmt.executeQuery();
			chatList = new ArrayList<ChatDTO>();
			while(rs.next()) {
				ChatDTO chat = new ChatDTO();
				chat.setChatID(rs.getInt("chatID"));
				chat.setFromID(rs.getString("fromID").replaceAll(" ", "&nbsp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll("\n", "<br>"));
				chat.setToID(rs.getString("toID").replaceAll(" ", "&nbsp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll("\n", "<br>"));
				chat.setChatContent(rs.getString("chatContent").replaceAll(" ", "&nbsp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll("\n", "<br>"));
				int chatTime = Integer.parseInt(rs.getString("chatTime").substring(11, 13));
				String timeType="오전";
				if (chatTime > 12) {
					timeType = "오후";
					chatTime -=12;
					
				}
				chat.setChatTime(rs.getString("chatTime").substring(0, 11) + " " + timeType + " " + chatTime + ":" + rs.getString("chatTime").substring(14, 16) + " ");
				chatList.add(chat);
			}
			
			// 특정 두 메시지가 A,B라고 있을때  A메시지의 fromID가  B메시지의toID와 같고
			// A메시지의 toID가 B메시지의 FromID와 같을 때 가장 최신에 있는 메시지를 1개만을 출력하기 위한 구문.
			for(int i = 0; i < chatList.size(); i++) {
				ChatDTO x = chatList.get(i);
				for(int j = 0; j < chatList.size(); j++) {
					ChatDTO y = chatList.get(j);
					if(x.getFromID().equals(y.getToID()) && x.getToID().equals(y.getFromID())) {
						if(x.getChatID() < y.getChatID()) {
							chatList.remove(x);
							i--;
							break;
						}else {
							chatList.remove(y);
							j--;
						}
					}
				}
			}
		} catch(Exception e) {
			e.printStackTrace();
		} finally {
			try {
				if(rs !=null) rs.close();
				if(pstmt !=null) pstmt.close();
				if(conn !=null) conn.close();
				
			}catch (Exception e) {
				e.printStackTrace();
			}
		}
		return chatList; //리스트 반환
	}
	
	public int submit(String fromID, String toID, String chatContent){
		
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		
		String SQL = "insert into chat values (null, ?, ?, ?, now(), 0)";
		try {
			conn = dataSource.getConnection();
			pstmt = conn.prepareStatement(SQL);
			pstmt.setString(1, fromID);
			pstmt.setString(2, toID);
			pstmt.setString(3, chatContent);
			return pstmt.executeUpdate();

		} catch(Exception e) {
			e.printStackTrace();
		} finally {
			try {
				if(rs !=null) rs.close();
				if(pstmt !=null) pstmt.close();
				if(conn !=null) conn.close();
				
			}catch (Exception e) {
				e.printStackTrace();
			}
		}
		return -1; //데이터베이스 오류를 발생시키는 것을 알려줌
	}
	// 메시지를 읽었는지, 안 읽었는지 알기위한 함수
	public int readChat(String fromID, String toID) {
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String SQL = "update chat set chatRead = 1 where (fromID = ? and toID = ?)";
		try {
			conn = dataSource.getConnection();
			pstmt = conn.prepareStatement(SQL);
			pstmt.setString(1, toID);
			pstmt.setString(2, fromID);
			return pstmt.executeUpdate();
		} catch(Exception e) {
			e.printStackTrace();
		} finally {
			try {
				if(rs !=null) rs.close();
				if(pstmt !=null) pstmt.close();
				if(conn !=null) conn.close();
				
			}catch (Exception e) {
				e.printStackTrace();
			}
		}
		return -1; //데이터베이스 오류를 발생시키는 것을 알려줌 . 실패 시 -1을 리턴해야함
	}
	// 안읽은 메시지의 개수를 모두 가져온다.
	public int getAllUnreadChat(String userID) {
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String SQL = "select count(chatID) from chat where toID= ? and chatRead = 0";
		try {
			conn = dataSource.getConnection();
			pstmt = conn.prepareStatement(SQL);
			pstmt.setString(1, userID);
			rs = pstmt.executeQuery();
			
			while(rs.next()) {
				return rs.getInt("count(chatID)");
			}
			return 0;
		} catch(Exception e) {
			e.printStackTrace();
		} finally {
			try {
				if(rs !=null) rs.close();
				if(pstmt !=null) pstmt.close();
				if(conn !=null) conn.close();
				
			}catch (Exception e) {
				e.printStackTrace();
			}
		}
		return -1; //데이터베이스 오류를 발생시키는 것을 알려줌 . 실패 시 -1을 리턴해야함
	}
}
