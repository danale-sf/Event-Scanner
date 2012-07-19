@RestResource(urlMapping='/v1/scan/*') 
global class MobileScan {
	
	@HttpGet
	global static String doGet() {
		return null;
	}
}