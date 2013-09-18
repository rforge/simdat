package simdat;
/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 *
 * @author maarten
 */
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.swing.JOptionPane;
import org.rosuda.REngine.REXPMismatchException;
import org.rosuda.REngine.REngineException;
import simdat.SimDat;
import simdat.wizards.*;
import org.rosuda.JGR.JGR;
import org.rosuda.JRI.Rengine;
import org.rosuda.REngine.*;
import org.rosuda.REngine.REngine;
import org.rosuda.REngine.JRI.JRIEngine;
//import org.rosuda.deducer.DefaultRConnector;
//import org.rosuda.deducer.RConnector;
public class NewMain {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) throws REXPMismatchException {
        // TODO code application logic here
        //boolean JGR = false;
        //REXP mr;
        //JGR jgr = new JGR();
        /*try {
            mr = JGR.idleEval("JGR()");
        } catch (REngineException ex) {
            Logger.getLogger(NewMain.class.getName()).log(Level.SEVERE, null, ex);
        }
         */


        System.loadLibrary("jri");
        String[] rargs = { "--save" };
        SimDat simdat = new SimDat(false);
        try {
            Rengine rEngine = new org.rosuda.JRI.Rengine(rargs, true, null);
            RConnector rConnection = new DefaultRConnector(new JRIEngine(rEngine));
            SimDat.setRConnector(rConnection);
		//REngine rEngine = new JRIEngine(rargs, MAINRCONSOLE);
	} catch (Exception e) {
		JOptionPane.showMessageDialog(null,
				"Unable to start R: " + e.getMessage(),
				"REngine problem", JOptionPane.ERROR_MESSAGE);
		System.err.println("Cannot start REngine " + e);
		System.exit(1);
	}


        //simdat.startNoJGR();
        SimDat.GlobalEval(SimDat.guiEnv + "<- new.env()");
        SimDat.GlobalEval("source(\"/home/maarten/Documents/RForge/simdat/sourcing.R\")");
        SimDat.eval("tmp <- ANOVA()");
        SimDat.eval("tmp2 <- GLM()");

        //String[]
        //JOptionPane.showMessageDialog(null,result.asString());
        //REXPLogical result = (REXPLogical) SimDat.eval("is(tmp,\"SimDatModel\")");
        //Boolean ttrue = result.isTRUE()[0];
        //JOptionPane.showMessageDialog(null,result.asString());
        //REXP mr = SimDat.eval("table");
        
        //Rengine r = new Rengine();

        SimDat.refreshModels();
        JOptionPane.showMessageDialog(null,SimDat.MODELS.toString());

        SimDat.startViewerAndWait();


        //AnovaWizard aov = new AnovaWizard("bobo",true);
        //int ret = aov.showModalDialog();


        
        //
    }

}
