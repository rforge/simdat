package simdat.wizards;

import simdat.SimDat;

import org.rosuda.JGR.util.ErrorMsg;

import simdat.toolkit.RdfRowEditor;

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import javax.swing.border.*;

import org.rosuda.JGR.robjects.*;

public class RmGamlssModelDialog extends JPanel implements ActionListener {

    private String rBetweenDataName;
    private String rWithinDataName;
    //private String errorRDataName;
    private String curEnv;
    private RdfRowEditor betweenDataEditor;
    private RdfRowEditor withinDataEditor;
    private JPanel contentPanel;
    
    public RmGamlssModelDialog(String rBetweenName, String rWithinName, String curEnv) {
        this.rBetweenDataName = rBetweenName;
        this.rWithinDataName = rWithinName;
        this.curEnv = curEnv;
        //errorRDataName = dataName + "@errorSD";

        //errorRDataName = "jkhsdfkjhksdfjh";
        //String cmd = errorRDataName + "<- " + dataName + "@errorSD";
        //SimDat.eval(cmd);

        setLayout(new java.awt.BorderLayout());
        
        contentPanel = getContentPanel();
        this.add(contentPanel);

    }

    public JPanel getContentPanel() {
        JPanel contentPanel1 = new JPanel();
        contentPanel1.setLayout(new GridLayout(2,1));
        //contentPanel1.setLayout(new java.awt.BorderLayout());

        JPanel jPanel1 = new JPanel();
        jPanel1.setLayout(new GridLayout(1,1));
        jPanel1.setBorder(javax.swing.BorderFactory.createTitledBorder("Between model and parameters"));
        betweenDataEditor = new RdfRowEditor(rBetweenDataName,curEnv);
        jPanel1.add(betweenDataEditor);
        contentPanel1.add(jPanel1);

        JPanel jPanel2 = new JPanel();
        jPanel2.setLayout(new GridLayout(1,1));
        jPanel2.setBorder(javax.swing.BorderFactory.createTitledBorder("Within parameters"));
        withinDataEditor = new RdfRowEditor(rWithinDataName,curEnv);
        jPanel2.add(withinDataEditor);
        contentPanel1.add(jPanel2);
        
        return contentPanel1;
    }

    public void refresh() {
        betweenDataEditor.refresh();
        withinDataEditor.refresh();
    }

    public void setData(String betweenDataName, String withinDataName, String curEnv) {
        rBetweenDataName = betweenDataName;
        rWithinDataName = withinDataName;
        this.curEnv = curEnv;
        betweenDataEditor.setData(rBetweenDataName,curEnv);
        withinDataEditor.setData(rWithinDataName,curEnv);
    }
    
    public void actionPerformed(ActionEvent arg0) {
        String cmd = arg0.getActionCommand();
    }

    /*
    public Boolean MakeModel(String rModelName, Boolean exists) {
        // objectName is the name of the df
        // TODO: model_id
        String cmd;
        if(exists) {
            cmd = rModelName + "<- simulate(SimDatModelFromGlmWizardDf(df=" + rDataName + ",model=" + rModelName +"))";
        } else {
            cmd = rModelName + "<- simulate(SimDatModelFromGlmWizardDf(df=" + rDataName + ",model_name=" + rModelName +"))";
        }
        SimDat.execute(cmd);

        //SimDat.eval(cmd);
        SimDat.refreshModels();
        try{
            String cls = SimDat.eval("class(" + rDataName+")").asString();
            int result = SimDat.eval("nrow(getData("+rModelName+"))").asInteger();
            if(result > 0) {

            }
        } catch(Exception e){
            new ErrorMsg(e);
        }
        return false;
    }
     * 
     */
}
