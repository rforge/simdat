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
public class AnovaWizard extends Wizard {

    private SpecifyNewGlmDialog aov0;
    private WizardPanelDescriptor aov0d;
    private GLMDialog aov1;
    private WizardPanelDescriptor aov1d;
    private GamlssModelDialog aov2;
    private WizardPanelDescriptor aov2d;

    private Boolean newModel;

    private String subEnv = "AnovaWizardEnv";
    private String baseEnv = SimDat.guiEnv;
    private String curEnv = baseEnv + "$" + subEnv;

    private String rModelName;
    private String rAnovaWizMod = "myAnovaWizardModel";
    private String rGamlssDf = "myGamlssDf";

    public AnovaWizard(String ModelName, boolean NewModel) {

        super();

        this.rModelName = ModelName;
        this.newModel = NewModel;

        if (((REXPLogical) SimDat.eval("!exists('" + subEnv + "') || !is.environment(" + subEnv + ")",baseEnv)).isTRUE()[0]) {
            SimDat.eval(subEnv + "<- new.env()",baseEnv);
        }

        if(newModel) {
            aov0 = new SpecifyNewGlmDialog(true,true,false,true,curEnv);
            aov0d = new AnovaWizard.ANOVA0Descriptor();
        } else {
            // make copy of model into current environment
            SimDat.eval(subEnv + "$" + rModelName + "<-" + rModelName,baseEnv);

            aov1 = new GLMDialog(true,false,true,rModelName,curEnv);
            aov1d = new AnovaWizard.ANOVA1Descriptor();
        }
        
        aov2 = new GamlssModelDialog(rGamlssDf,curEnv);
        aov2d = new AnovaWizard.ANOVA2Descriptor();

        this.getDialog().setTitle("ANOVA model");

        if(newModel) {
            this.registerWizardPanel(ANOVA0Descriptor.IDENTIFIER, aov0d);
        } else {
            this.registerWizardPanel(ANOVA1Descriptor.IDENTIFIER, aov1d);
        }
        
        this.registerWizardPanel(ANOVA2Descriptor.IDENTIFIER, aov2d);
        if(newModel) {
            this.setCurrentPanel(ANOVA0Descriptor.IDENTIFIER);
        } else {
            this.setCurrentPanel(ANOVA1Descriptor.IDENTIFIER);
        }
    };

    @Override
    public void onFinish() {
        // make the model
        //aov2.MakeModel(aov1.getModelName(),true);
        SimDat.execute(rModelName + "<- makeSimDatModel(" + rAnovaWizMod + "," + rGamlssDf + ")",curEnv);

        // copy to base env
        // TODO: ask to override?
        SimDat.execute(rModelName + "<-" + subEnv + "$" + rModelName,baseEnv);
    }

    public void makeAnovaWizModel() {
        SimDat.execute(rAnovaWizMod + "<- AnovaWizardModel(dep=depList[[1]],fac=facList,fam=fam)",curEnv);
    }
    public void makeGamlssDf() {
        SimDat.execute(rGamlssDf + "<- getWizardDf( " + rAnovaWizMod + ")",curEnv);
    }

    public class ANOVA0Descriptor extends WizardPanelDescriptor {
        public static final String IDENTIFIER = "ANOVA0_PANEL";

         public ANOVA0Descriptor() {
            super(IDENTIFIER, aov0);
        }

        public String getHelpUrl() {
            return WizardPanelDescriptor.baseUrl + "pmwiki.php?n=Wizard.SpecifyNewGlm";
        }
        
        public Object getBackPanelDescriptor() {
            return null;
        }

        public Object getNextPanelDescriptor() {
            return ANOVA2Descriptor.IDENTIFIER;
            //return ANOVA2Descriptor.IDENTIFIER;
        }

        public void aboutToHidePanel() {
            //boolean ok = aov1.MakeRdf(this.IDENTIFIER);
            aov0.makeFamily();
            SimDat.eval("facList <- makeFactorialDesign(facList)",curEnv);
            makeAnovaWizModel();
            makeGamlssDf();
            
        }


    }

    public class ANOVA1Descriptor extends WizardPanelDescriptor {
        
        public static final String IDENTIFIER = "ANOVA1_PANEL";

        public ANOVA1Descriptor() {

            super(IDENTIFIER, aov1);

        }

        public String getHelpUrl() {
            return WizardPanelDescriptor.baseUrl + "pmwiki.php?n=Wizard.AnovaDialog";
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
            //boolean ok = aov1.MakeRdf(this.IDENTIFIER);

            // make lists
            boolean ok = aov1.MakeVarLists(true, true, false, true);
            if(ok) {
                makeAnovaWizModel();
                makeGamlssDf();
            }

        }
    }

     public class ANOVA2Descriptor extends WizardPanelDescriptor {

        public static final String IDENTIFIER = "ANOVA2_PANEL";

        public ANOVA2Descriptor() {

            super(IDENTIFIER, aov2);
        }

        public String getHelpUrl() {
            return WizardPanelDescriptor.baseUrl + "pmwiki.php?n=Wizard.GamlssModel";
        }

        public Object getNextPanelDescriptor() {
            return FINISH;
        }

        public Object getBackPanelDescriptor() {
            if(newModel)
                return ANOVA0Descriptor.IDENTIFIER;
            else
                return ANOVA1Descriptor.IDENTIFIER;
        }

        public void aboutToDisplayPanel() {
            //aov2.setData(SimDat.guiEnv + "$" + ANOVA1Descriptor.IDENTIFIER);
            //if(newModel)
            //    aov2.setData(rGamlssDf);
            //else
            //    aov2.setData(ANOVA1Descriptor.IDENTIFIER);
            aov2.setData(rGamlssDf,curEnv);
            aov2.refresh();
        }

        public void aboutToHidePanel() {


        }


    }

}
