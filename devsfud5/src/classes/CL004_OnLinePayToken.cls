/*
*	Utils class 
*	23 Enero 2013 - Jairo Guzman - admin all on line pay token operations 
*/

public class CL004_OnLinePayToken {
	
	/*object properties*/	
	public string Token{get;private set;}
	
	
	/*contructors*/
	public  CL004_OnLinePayToken(string strToken){
	
		Token = strToken;
	}

	/*validate token structure*/
	public Boolean ValidateTokenFormat(){
		return CL000_Utils.ValidateStandarTokenFormat(Token);
	}	

}