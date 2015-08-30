package servlets;

import org.json.*;
import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet implementation class JsonProviderServlet
 */
@WebServlet("/JsonProviderServlet")
public class JsonProviderServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	/*private String list = "["
			+ "{"
			+ "\"name\":\"Emma Maersk\","
			+ "\"imo\":\"9321483\","
			+ "\"mmsi\":\"220417000\","
			+ "\"type\":\"Vehicles Carrier\""
			+ "},"
			+ "{"
			+ "\"name\":\"Gentle Leader\","
			+ "\"imo\":\"9391567\","
			+ "\"mmsi\":\"311003300\","
			+ "\"type\":\"Container Ship\""
			+ "},"
			+ "{"
			+ "\"name\":\"Handytankers Glory\","
			+ "\"imo\":\"9339624\","
			+ "\"mmsi\":\"309553000\","
			+ "\"type\":\"Chemical Oil Products Tanker\""
			+ "},"
			+ "{"
			+ "\"name\":\"Cantankerous\","
			+ "\"mmsi\":\"227786220\","
			+ "\"type\":\"Chemical Oil Products Tanker\""
			+ "}"	
			+ "]";
       */
    /**
     * @see HttpServlet#HttpServlet()
     */
    public JsonProviderServlet() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
		//read CSV, parse into JSON and send
		JSONArray csvList = readCSVFile();
		csvList.toString();
		response.setContentType("application/json");
		request.setAttribute("vessels", csvList);
		//out.println(csvList);
		//response.getWriter().append("Served at: ").append(request.getContextPath());
		this.getServletContext().getRequestDispatcher("/WEB-INF/vessels.jsp").forward(request, response);
		
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doGet(request, response);
	}

	JSONArray readCSVFile(){
						
		BufferedReader br = null;
		String line = "";
		JSONArray list = new JSONArray();
		
		try {

			String csvFile = this.getServletContext().getRealPath("/vessels.csv").toString();
			
			

			br = new BufferedReader(new FileReader(csvFile));
			br.readLine();
			while ((line = br.readLine()) != null) {
				System.out.println(line);
				String[] entry = line.split("\\|");
				
				// vesselname | imo | mmsi | type | longitude | latitude
				JSONObject obj = new JSONObject();
				obj.append("name", entry[0]);
				obj.append("imo", entry[1]);
				obj.append("mmsi", entry[2]);
				obj.append("type", entry[3]);
				obj.append("longitude", entry[4]);
				obj.append("latitude", entry[5]);
				
				list.put(obj);
				
				/*System.out.println("Vesselname:  " + entry[0] 
	                                 + " , imo: " + entry[1] 
                            		 + " , mmsi: " + entry[2]
                    				 + " , type: " + entry[3]
            						 + " , longitude: " + entry[4]
    								 + " , latitude: " + entry[5]);*/
				
			}

		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			if (br != null) {
				try {
					br.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
		return list;

	}
	
}
