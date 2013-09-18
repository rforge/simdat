package simdat.wizards;

import simdat.SimDat;

import org.rosuda.JGR.util.ErrorMsg;

import simdat.toolkit.RdfRowEditor;

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import javax.swing.border.*;

import org.rosuda.JGR.robjects.*;

public class GamlssModelDialog extends JPanel implements ActionListener {

    private String rDataName;
    private RdfRowEditor dataEditor;
    private JPanel contentPanel;

    private String curEnv;
    
    public GamlssModelDialog(String rDataName, String curEnv) {
        //rDataName = dataName;
        this.curEnv = curEnv;
        this.rDataName = rDataName;
        setLayout(new java.awt.BorderLayout());

        // create the data frame for editing

        contentPanel = getContentPanel();
        this.add(contentPanel);

    }

    public JPanel getContentPanel() {
        JPanel contentPanel1 = new JPanel();
        JPanel jPanel1 = new JPanel();

        contentPanel1.setLayout(new java.awt.BorderLayout());
        jPanel1.setLayout(new GridLayout(1,1));

        dataEditor = new RdfRowEditor(rDataName,curEnv);

        jPanel1.add(dataEditor);

        contentPanel1.add(jPanel1);

        return contentPanel1;
    }

    public void refresh() {
        dataEditor.refresh();
    }

    public void setData(String dataName) {
        rDataName = dataName;
        dataEditor.setData(rDataName,curEnv);
    }

    public void setData(String dataName, String curEnv) {
        rDataName = dataName;
        this.curEnv = curEnv;
        dataEditor.setData(rDataName,curEnv);
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
