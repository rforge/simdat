/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package simdat.wizards;

import simdat.toolkit.MetricVariableListEditor;
import simdat.toolkit.NonmetricVariableListEditor;
import simdat.toolkit.DistributionList;
import simdat.SimDat;

import org.rosuda.REngine.*;

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import javax.swing.border.*;

/**
 *
 * @author maarten
 */
public class SpecifyNewRMDialog extends JPanel {

    private static String subEnv = "specifyNewRMDialog";
    private String baseEnv = SimDat.guiEnv;
    private String curEnv = baseEnv + "$" + subEnv;
    private boolean sDependent = true;
    private boolean sBetweenFactor = true;
    private boolean sWithinFactor = true;
    private boolean sNumeric = true;
    private boolean sFamily = true;
    private String depName = "Dependent";
    private String bfacName = "Between Factors(s)";
    private String wfacName = "Within Factors(s)";
    private String numName = "Covariate(s)";
    private String famName = "Distribution";
    private boolean keepEnv = false;
    private MetricVariableListEditor depEditor;
    private NonmetricVariableListEditor bfacEditor;
    private NonmetricVariableListEditor wfacEditor;
    private MetricVariableListEditor numEditor;
    private DistributionList famEditor;
    private JPanel contentPanel;

    public SpecifyNewRMDialog(boolean addDependent, boolean addBetweenFactor, boolean addWithinFactor, boolean addNumeric, boolean addFamily, String curEnv) {

        this.curEnv = curEnv;
        sDependent = addDependent;
        sWithinFactor = addWithinFactor;
        sBetweenFactor = addBetweenFactor;
        sNumeric = addNumeric;
        sFamily = addFamily;

        makeREnv();

        if(sDependent) depEditor = new MetricVariableListEditor("depList",curEnv,true,true,false,false,1);
        if(sBetweenFactor) bfacEditor = new NonmetricVariableListEditor("bfacList",curEnv,true,true,true,false,1000);
        if(sWithinFactor) wfacEditor = new NonmetricVariableListEditor("wfacList",curEnv,true,true,true,false,1000);
        if(sNumeric) numEditor = new MetricVariableListEditor("numList",curEnv,true,true,true,true,1000);
        if(sFamily) famEditor = new DistributionList();

        setLayout(new java.awt.BorderLayout());
        contentPanel = getContentPanel();
        this.add(contentPanel);

        this.refresh();


    }

    public SpecifyNewRMDialog(boolean addDependent, boolean addBetweenFactor, boolean addWithinFactor, boolean addNumeric, boolean addFamily) {

        this(addDependent,addBetweenFactor,addWithinFactor,addNumeric,addFamily,subEnv);


    }

    public JPanel getContentPanel() {
        JPanel contentPanel1 = new JPanel();

        int rows = 0;
        if (sDependent) {
            rows += 1;
        }
        if (sBetweenFactor) {
            rows += 1;
        }
        if (sWithinFactor) {
            rows += 1;
        }
        if (sNumeric) {
            rows += 1;
        }
        if (sFamily) {
            rows += 1;
        }

        contentPanel1.setLayout(new GridLayout(rows, 1));

        if (sDependent) {
            JPanel depPanel = new JPanel();
            depPanel.setLayout(new GridLayout(1,1));
            depPanel.setBorder(javax.swing.BorderFactory.createTitledBorder(depName));
            depPanel.setMinimumSize(new Dimension(10,50));
            depPanel.add(depEditor);
            contentPanel1.add(depPanel);
        }
        if (sBetweenFactor) {
            JPanel bfacPanel = new JPanel();
            bfacPanel.setLayout(new GridLayout(1,1));
            bfacPanel.setBorder(javax.swing.BorderFactory.createTitledBorder(bfacName));
            bfacPanel.setMinimumSize(new Dimension(10,50));
            bfacPanel.add(bfacEditor);
            contentPanel1.add(bfacPanel);
        }
        if (sWithinFactor) {
            JPanel wfacPanel = new JPanel();
            wfacPanel.setLayout(new GridLayout(1,1));
            wfacPanel.setBorder(javax.swing.BorderFactory.createTitledBorder(wfacName));
            wfacPanel.setMinimumSize(new Dimension(10,50));
            wfacPanel.add(wfacEditor);
            contentPanel1.add(wfacPanel);
        }
        if (sNumeric) {
            JPanel numPanel = new JPanel();
            numPanel.setLayout(new GridLayout(1,1));
            numPanel.setBorder(javax.swing.BorderFactory.createTitledBorder(numName));
            numPanel.setMinimumSize(new Dimension(10,50));
            numPanel.add(numEditor);
            contentPanel1.add(numPanel);
        }
        if (sFamily) {
            JPanel famPanel = new JPanel();
            famPanel.setLayout(new GridLayout(1,1));
            famPanel.setBorder(javax.swing.BorderFactory.createTitledBorder(famName));
            famPanel.setMinimumSize(new Dimension(10,50));
            famPanel.add(famEditor);
            contentPanel1.add(famPanel);
        }

        return contentPanel1;
    }

    public void makeREnv() {
        //SimDat.execute(subEnv + "<- new.env()");
        SimDat.execute("depList <- VariableList(list())",curEnv);
        SimDat.execute("bfacList <- VariableList(list())",curEnv);
        SimDat.execute("wfacList <- VariableList(list())",curEnv);
        SimDat.execute("numList <- VariableList(list())",curEnv);
    }

    public void makeFamily() {
        SimDat.execute("fam <- .SimDatGetDistributionFromName(\"" + famEditor.getModel().getSelectedItem().toString() + "\")", curEnv);
    }

    public void refresh() {
        if(sDependent) depEditor.refresh();
        if(sBetweenFactor) bfacEditor.refresh();
        if(sWithinFactor) bfacEditor.refresh();
        if(sNumeric) numEditor.refresh();
        //famEditor.refresh();
    }
}
