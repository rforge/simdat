/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package simdat.wizards;

import javax.swing.JPanel;
import simdat.SimDat;

import org.rosuda.REngine.RList;
import org.rosuda.REngine.REXPMismatchException;
import org.rosuda.JGR.util.ErrorMsg;
import org.rosuda.REngine.REXPLogical;

/**
 *
 * @author maarten
 */
public class RmAnovaWizard extends Wizard {

    private SpecifyNewRMDialog aov0;
    private WizardPanelDescriptor aov0d;
    private RMDialog aov1;
    private WizardPanelDescriptor aov1d;
    private RmGamlssModelDialog aov2;
    private WizardPanelDescriptor aov2d;

    private Boolean newModel;

    private String subEnv = "RmAnovaWizardEnv";
    private String baseEnv = SimDat.guiEnv;
    private String curEnv = baseEnv + "$" + subEnv;

    private String rModelName;
    private String rRmAnovaWizMod = "myRmAnovaWizardModel";
    private String rGamlssDf = "myRmGamlssDf";
    private String rWithinDf = "myWithinDf";

    public RmAnovaWizard(String ModelName, Boolean NewModel) {

        super();

        newModel = NewModel;

        this.rModelName = ModelName;

        if (((REXPLogical) SimDat.eval("!exists('" + subEnv + "') || !is.environment(" + subEnv + ")",baseEnv)).isTRUE()[0]) {
            SimDat.eval(subEnv + "<- new.env()");
        }
        
        if(newModel) {
            aov0 = new SpecifyNewRMDialog(true,true,true,false,true);
            aov0d = new RmAnovaWizard.ANOVA0Descriptor();
        } else {
            // make copy of model into current environment
            SimDat.eval(subEnv + "$" + rModelName + "<-" + rModelName,baseEnv);
            
            aov1 = new RMDialog(true,true,false,true,rModelName,curEnv);
            aov1d = new RmAnovaWizard.ANOVA1Descriptor();
        }
        
        //aov2 = new RmGamlssModelDialog(SimDat.guiEnv + "$" + ANOVA1Descriptor.IDENTIFIER);
        aov2 = new RmGamlssModelDialog(rGamlssDf,rWithinDf,curEnv);
        aov2d = new RmAnovaWizard.ANOVA2Descriptor();

        this.getDialog().setTitle("Repeated Measures model");

        this.registerWizardPanel(ANOVA1Descriptor.IDENTIFIER, aov1d);
        this.registerWizardPanel(ANOVA2Descriptor.IDENTIFIER, aov2d);
        this.setCurrentPanel(ANOVA1Descriptor.IDENTIFIER);
    };

    @Override
    public void onFinish() {
        // make the model
        //aov2.MakeModel(aov1.getModelName(),true);
        SimDat.execute(rModelName + "<- makeSimDatModel(" + rRmAnovaWizMod + ", bdf = " + rGamlssDf + ", wdf = " + rWithinDf + ")",curEnv);

        // copy to base env
        // TODO: ask to override?
        SimDat.execute(rModelName + "<-" + subEnv + "$" + rModelName,baseEnv);
    }

    public void makeRmAnovaWizModel() {
        SimDat.execute(rRmAnovaWizMod + "<- RmAnovaWizardModel(dep=depList[[1]],bfac=bfacList,wfac=wfacList,fam=fam)",curEnv);
    }
    public void makeGamlssDf() {
        SimDat.execute(rGamlssDf + "<- getWizardDf( " + rRmAnovaWizMod + ",which='between')",curEnv);
        SimDat.execute(rWithinDf + "<- getWizardDf( " + rRmAnovaWizMod + ",which='within')",curEnv);
    }

    public class ANOVA0Descriptor extends WizardPanelDescriptor {

        public static final String IDENTIFIER = "RM0_PANEL";

        public ANOVA0Descriptor() {

            super(IDENTIFIER, aov0);

        }

        public Object getNextPanelDescriptor() {
            return ANOVA2Descriptor.IDENTIFIER;
            //return ANOVA2Descriptor.IDENTIFIER;
        }

        public Object getBackPanelDescriptor() {
            return null;
        }

        public void aboutToHidePanel() {

            aov0.makeFamily();
            makeRmAnovaWizModel();
            makeGamlssDf();
            //boolean ok = aov1.MakeRdf(this.IDENTIFIER);

        }
    }

    public class ANOVA1Descriptor extends WizardPanelDescriptor {
        
        public static final String IDENTIFIER = "RM1_PANEL";

        public ANOVA1Descriptor() {

            super(IDENTIFIER, aov1);

        }

        public Object getNextPanelDescriptor() {
            return ANOVA2Descriptor.IDENTIFIER;
            //return ANOVA2Descriptor.IDENTIFIER;
        }

        public Object getBackPanelDescriptor() {
            return null;
        }

        public void aboutToHidePanel() {
            // make the Rdf
            //String name = SimDat.guiEnv + "$" + this.IDENTIFIER;
            //boolean ok = aov1.MakeRdf(SimDat.guiEnv + "$" + this.IDENTIFIER);
            //boolean ok = aov1.MakeRdf(this.IDENTIFIER);
            /*
            RList data = null;
            try {
               data = SimDat.eval(SimDat.guiEnv + "$" + ANOVA1Descriptor.IDENTIFIER).asList();
            } catch (REXPMismatchException e) {
                new ErrorMsg(e);
            }
             *
             */
            //if(ok) {
            //    aov2.setData(name);
            //    aov2.refresh();
            //}
            boolean ok = aov1.MakeVarLists(true, false, true, false, true);
            if(ok) {
                makeRmAnovaWizModel();
                makeGamlssDf();
            }
        }
    }

     public class ANOVA2Descriptor extends WizardPanelDescriptor {

        public static final String IDENTIFIER = "RM2_PANEL";

        public ANOVA2Descriptor() {

            super(IDENTIFIER, aov2);
        }

        public Object getNextPanelDescriptor() {
            return FINISH;
        }

        public Object getBackPanelDescriptor() {
            //return ANOVA1Descriptor.IDENTIFIER;
            if(newModel)
                return ANOVA0Descriptor.IDENTIFIER;
            else
                return ANOVA1Descriptor.IDENTIFIER;
        }

        public void aboutToDisplayPanel() {
            //aov2.setData(SimDat.guiEnv + "$" + ANOVA1Descriptor.IDENTIFIER);
            //aov2.setData(ANOVA1Descriptor.IDENTIFIER);
            //aov2.refresh();
            /*
            if(newModel)
                aov2.setData(ANOVA0Descriptor.IDENTIFIER);
            else
                aov2.setData(ANOVA1Descriptor.IDENTIFIER);
            aov2.refresh();
             *
             */
            aov2.setData(rGamlssDf,rWithinDf,curEnv);
            aov2.refresh();
        }

        public void aboutToHidePanel() {


        }


    }

}
