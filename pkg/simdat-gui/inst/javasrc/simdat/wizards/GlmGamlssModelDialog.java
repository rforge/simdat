package simdat.wizards;

import simdat.SimDat;

import org.rosuda.JGR.util.ErrorMsg;

import simdat.toolkit.RdfRowEditor;
import simdat.toolkit.CovariateEditor;

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import javax.swing.border.*;

import org.rosuda.JGR.robjects.*;

public class GlmGamlssModelDialog extends JPanel implements ActionListener {

    private String rBetweenDataName;
    private String rNumModelDataName;
    //private String errorRDataName;
    private String curEnv;
    private RdfRowEditor betweenDataEditor;
    private CovariateEditor numModelDataEditor;
    private JPanel contentPanel;

    public GlmGamlssModelDialog(String rBetweenName, String rNumModelName, String curEnv) {
        this.rBetweenDataName = rBetweenName;
        this.rNumModelDataName = rNumModelName;
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
        jPanel1.setBorder(javax.swing.BorderFactory.createTitledBorder("Between model"));
        betweenDataEditor = new RdfRowEditor(rBetweenDataName,curEnv);
        jPanel1.add(betweenDataEditor);
        contentPanel1.add(jPanel1);

        JPanel jPanel2 = new JPanel();
        jPanel2.setLayout(new GridLayout(1,1));
        jPanel2.setBorder(javax.swing.BorderFactory.createTitledBorder("Covariate models"));
        numModelDataEditor = new CovariateEditor(rNumModelDataName,curEnv);
        jPanel2.add(numModelDataEditor);
        contentPanel1.add(jPanel2);

        return contentPanel1;
    }

    public void refresh() {
        betweenDataEditor.refresh();
        numModelDataEditor.refresh();
    }

    public void setData(String betweenDataName, String numModelDataName, String curEnv) {
        rBetweenDataName = betweenDataName;
        rNumModelDataName = numModelDataName;
        this.curEnv = curEnv;
        betweenDataEditor.setData(rBetweenDataName,curEnv);
        numModelDataEditor.setData(rNumModelDataName,curEnv);
    }

    public void actionPerformed(ActionEvent arg0) {
        String cmd = arg0.getActionCommand();
    }

}
