package simdat;

import org.rosuda.REngine.REXP;
import org.rosuda.REngine.REngine;
//import org.rosuda.REngine.REXPEnvironment;
import org.w3c.dom.Document;

public interface RConnector {

	public void execute(String cmd);
        //public void execute(String cmd, REXPEnvironment where);
	public void execute(String cmd,boolean addToHist);
        //public void execute(String cmd, REXPEnvironment where, boolean addToHist);
	public void execute(String cmd,boolean addToHist,String title,Document xmlDialogState);
	public REXP eval(String cmd);
        //public REXP eval(String cmd, REXPEnvironment where);
	public REXP idleEval(String cmd);
        //public REXP idleEval(String cmd, REXPEnvironment where);
	public REngine getREngine();
}
