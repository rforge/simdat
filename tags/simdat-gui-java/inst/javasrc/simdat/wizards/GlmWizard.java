/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package simdat.wizards;

import simdat.toolkit.CovariateEditor;

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
public class GlmWizard extends Wizard {

    private String subEnv = "GlmWizardEnv";
    private String baseEnv = SimDat.guiEnv;
    private String curEnv = baseEnv + "$" + subEnv;
    private String rModelName;
    private String rGlmWizMod = "myGlmWizardModel";
    private String rGlmGamlssDf = "myGamlssDf";
    private String rNumModelDf = "myNumModelDf";
    private SpecifyNewGlmDialog glm0;
    private WizardPanelDescriptor glm0d;
    private GLMDialog glm1;
    private WizardPanelDescriptor glm1d;
    private CovariateEditor glm2;
    private WizardPanelDescriptor glm2d;
    private GamlssModelDialog glm3;
    private WizardPanelDescriptor glm3d;
    private Boolean newModel;

    public GlmWizard(String ModelName, boolean NewModel) {

        super();

        this.rModelName = ModelName;
        this.newModel = NewModel;

        if (((REXPLogical) SimDat.eval("!exists('" + subEnv + "') || !is.environment(" + subEnv + ")", baseEnv)).isTRUE()[0]) {
            SimDat.eval(subEnv + "<- new.env()", baseEnv);
        }

        if (newModel) {
            glm0 = new SpecifyNewGlmDialog(true, true, true, true, curEnv);
            glm0d = new GlmWizard.GLM0Descriptor();
        } else {
            // make copy of model into current environment
            SimDat.eval(subEnv + "$" + rModelName + "<-" + rModelName, baseEnv);

            glm1 = new GLMDialog(true, true, true, rModelName, curEnv);
            glm1d = new GlmWizard.GLM1Descriptor();
        }

        glm2 = new CovariateEditor(rNumModelDf, curEnv);
        glm2d = new GlmWizard.GLM2Descriptor();

        glm3 = new GamlssModelDialog(rGlmGamlssDf, curEnv);
        glm3d = new GlmWizard.GLM3Descriptor();

        this.getDialog().setTitle("General Linear Model");

        if (newModel) {
            this.registerWizardPanel(GLM0Descriptor.IDENTIFIER, glm0d);
        } else {
            this.registerWizardPanel(GLM1Descriptor.IDENTIFIER, glm1d);
        }

        this.registerWizardPanel(GLM2Descriptor.IDENTIFIER, glm2d);
        this.registerWizardPanel(GLM3Descriptor.IDENTIFIER, glm3d);

        if (newModel) {
            this.setCurrentPanel(GLM0Descriptor.IDENTIFIER);
        } else {
            this.setCurrentPanel(GLM1Descriptor.IDENTIFIER);
        }
    }

    ;

    @Override
    public void onFinish() {
        // make the model
        //aov2.MakeModel(aov1.getModelName(),true);
        SimDat.execute(rModelName + "<- makeSimDatModel(" + rGlmWizMod + "," + rGlmGamlssDf + "," + rNumModelDf + ")", curEnv);

        // copy to base env
        // TODO: ask to override?
        SimDat.execute(rModelName + "<-" + subEnv + "$" + rModelName, baseEnv);
    }

    public void makeGlmWizModel() {
        SimDat.execute(rGlmWizMod + "<- GlmWizardModel(dep=depList[[1]],fac=facList,num=numList,mod=modList,fam=fam)", curEnv);
    }

    public void makeGamlssDf() {
        SimDat.execute(rGlmGamlssDf + "<- getWizardDf(" + rGlmWizMod + ",which=\"between\")", curEnv);
        SimDat.execute(rNumModelDf + "<- getWizardDf(" + rGlmWizMod + ",which='nummodel')", curEnv);
    }

    public class GLM0Descriptor extends WizardPanelDescriptor {

        public static final String IDENTIFIER = "GLM0_PANEL";

        public GLM0Descriptor() {
            super(IDENTIFIER, glm0);
        }

        public String getHelpUrl() {
            return WizardPanelDescriptor.baseUrl + "pmwiki.php?n=Wizard.SpecifyNewGlm";
        }

        public Object getBackPanelDescriptor() {
            return null;
        }

        public Object getNextPanelDescriptor() {

            if (glm0.hasNumeric()) {
                return GLM2Descriptor.IDENTIFIER;
            } else {
                return GLM3Descriptor.IDENTIFIER;

            }
            //return ANOVA2Descriptor.IDENTIFIER;
        }

        public void aboutToHidePanel() {
            //boolean ok = aov1.MakeRdf(this.IDENTIFIER);
            glm0.makeFamily();
            SimDat.eval("facList <- makeFactorialDesign(facList)", curEnv);
            makeGlmWizModel();
            makeGamlssDf();

        }
    }

    public class GLM1Descriptor extends WizardPanelDescriptor {

        public static final String IDENTIFIER = "GLM1_PANEL";

        public GLM1Descriptor() {

            super(IDENTIFIER, glm1);

        }

        public Object getNextPanelDescriptor() {
            if (glm1.hasNumeric()) {
                return GLM2Descriptor.IDENTIFIER;
            } else {
                return GLM3Descriptor.IDENTIFIER;
            }

            //return ANOVA2Descriptor.IDENTIFIER;
        }

        public String getHelpUrl() {
            return WizardPanelDescriptor.baseUrl + "pmwiki.php?n=Wizard.GlmDialog";
        }

        public Object getBackPanelDescriptor() {
            return null;
        }

        public void aboutToHidePanel() {
            // make the Rdf
            //String name = SimDat.guiEnv + "$" + this.IDENTIFIER;
            //boolean ok = aov1.MakeRdf(SimDat.guiEnv + "$" + this.IDENTIFIER);
            //boolean ok = glm1.MakeRdf(this.IDENTIFIER);
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
            boolean ok = glm1.MakeVarLists(true, false, false, true);
            if (ok) {
                makeGlmWizModel();
                makeGamlssDf();
            }
        }
    }

    public class GLM2Descriptor extends WizardPanelDescriptor {

        public static final String IDENTIFIER = "GLM2_PANEL";

        public GLM2Descriptor() {

            super(IDENTIFIER, glm2);
        }

        public Object getNextPanelDescriptor() {
            return GLM3Descriptor.IDENTIFIER;
        }

        public Object getBackPanelDescriptor() {
            if (newModel) {
                return GLM0Descriptor.IDENTIFIER;
            } else {
                return GLM1Descriptor.IDENTIFIER;
            }
        }

        public void aboutToDisplayPanel() {
            //aov2.setData(SimDat.guiEnv + "$" + ANOVA1Descriptor.IDENTIFIER);
            //glm2.setData(GLM1Descriptor.IDENTIFIER);
            //glm2.refresh();
            glm2.setData(rNumModelDf, curEnv);
            glm2.refresh();
        }

        public void aboutToHidePanel() {
            // make the model
            //glm2.MakeModel(glm1.getModelName(),true);
        }
    }

    public class GLM3Descriptor extends WizardPanelDescriptor {

        public static final String IDENTIFIER = "GLM3_PANEL";

        public GLM3Descriptor() {

            super(IDENTIFIER, glm3);
        }

        public Object getNextPanelDescriptor() {
            return FINISH;
        }

        public Object getBackPanelDescriptor() {
            if (newModel) {
                if (glm0.hasNumeric()) {
                    return GLM2Descriptor.IDENTIFIER;
                } else {
                    return GLM0Descriptor.IDENTIFIER;
                }
            } else {
                if (glm1.hasNumeric()) {
                    return GLM2Descriptor.IDENTIFIER;
                } else {
                    return GLM1Descriptor.IDENTIFIER;
                }
            }
        }

        public void aboutToDisplayPanel() {
            //aov2.setData(SimDat.guiEnv + "$" + ANOVA1Descriptor.IDENTIFIER);
            //glm2.setData(GLM1Descriptor.IDENTIFIER);
            //glm2.refresh();
            glm3.setData(rGlmGamlssDf, curEnv);
            glm3.refresh();
        }

        public void aboutToHidePanel() {
            // make the model
            //glm2.MakeModel(glm1.getModelName(),true);
            //glm3.MakeModel();
        }
    }
}
