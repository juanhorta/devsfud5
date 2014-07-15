/*
*	Utils class 
*	23 Enero 2013 - Jairo Guzman - admin all advertising token operations 
*/
public class CL003_AdvertisingToken {

	/*object properties*/	
	public string Token{get;private set;}
	
	
	/*contructors*/
	public  CL003_AdvertisingToken(string strToken){
	
		Token = strToken;
	}

	/*validate token structure*/
	public Boolean ValidateTokenFormat(){
		return CL000_Utils.ValidateStandarTokenFormat(Token);
	}
}