public class CheckRecursive {
    
    private static boolean run = true;
    
    //method to check and return static boolean status
    public static boolean runonce(){
        if(run){
            run = false;
            return true;
        }else{
            return run;
        }
    }

}