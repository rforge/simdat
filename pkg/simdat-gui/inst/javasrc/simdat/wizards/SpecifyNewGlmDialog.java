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
public class SpecifyNewGlmDialog extends JPanel {

    private static String subEnv = "specifyNewGlmDialog";
    private String curEnv = SimDat.guiEnv + "$" + subEnv;
    private boolean sDependent = true;
    private boolean sFactor = true;
    private boolean sNumeric = true;
    private boolean sFamily = true;
    private String depName = "Dependent(s)";
    private String facName = "Factors(s)";
    private String numName = "Covariate(s)";
    private String famName = "Distribution";
    private boolean keepEnv = false;
    private MetricVariableListEditor depEditor;
    private NonmetricVariableListEditor facEditor;
    private MetricVariableListEditor numEditor;
    private DistributionList famEditor;
    private JPanel contentPanel;

    public SpecifyNewGlmDialog(boolean addDependent, boolean addFactor, boolean addNumeric, boolean addFamily, String curEnv) {

        this.curEnv = curEnv;
        sDependent = addDependent;
        sFactor = addFactor;
        sNumeric = addNumeric;
        sFamily = addFamily;

        //curEnv = SimDat.guiEnv + "$" + subEnv;

        makeREnv();

        /*
        boolean envDefined = ((REXPLogical) SimDat.eval("exists('" + subEnv + "') && is.environment(" + subEnv + ")")).isTRUE()[0];
        if (envDefined && keepEnv) {
            makeREnv();
            //SimDat.eval(guiEnv+"<-new.env(parent=emptyenv())");
            //TODO: raise ERROR
        } else {
            makeREnv();
        }
         * 
         */

        if(sDependent) depEditor = new MetricVariableListEditor("depList",curEnv,true,true,false,false,1);
        if(sFactor) facEditor = new NonmetricVariableListEditor("facList",curEnv,true,true,true,false,1000);
        if(sNumeric) numEditor = new MetricVariableListEditor("numList",curEnv,true,true,true,true,1000);
        if(sFamily) famEditor = new DistributionList();

        setLayout(new java.awt.BorderLayout());
        contentPanel = getContentPanel();
        this.add(contentPanel);

        this.refresh();


    }

    public SpecifyNewGlmDialog(boolean addDependent, boolean addFactor, boolean addNumeric, boolean addFamily) {

        this(addDependent,addFactor,addNumeric,addFamily,subEnv);


    }

    public JPanel getContentPanel() {
        JPanel contentPanel1 = new JPanel();

        int rows = 0;
        if (sDependent) {
            rows += 1;
        }
        if (sFactor) {
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
        if (sFactor) {
            JPanel facPanel = new JPanel();
            facPanel.setLayout(new GridLayout(1,1));
            facPanel.setBorder(javax.swing.BorderFactory.createTitledBorder(facName));
            facPanel.setMinimumSize(new Dimension(10,50));
            facPanel.add(facEditor);
            contentPanel1.add(facPanel);
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

    public boolean hasDependent()
    {
        Boolean out = false;
        if(this.depEditor.nValues() > 0)
            out = true;
        return out;
    }
    public boolean hasFactor()
    {
        Boolean out = false;
        if(this.facEditor.nValues() > 0)
            out = true;
        return out;
    }
    public boolean hasNumeric()
    {
        Boolean out = false;
        if(this.numEditor.nValues() > 0)
            out = true;
        return out;
    }
    public boolean hasDistribution()
    {
        Boolean out = false;
        if(this.famEditor.getSelectedObjects().length > 0)
            out = true;
        return out;
    }

    public void makeREnv() {
        //SimDat.execute(subEnv + "<- new.env()");
        SimDat.execute("depList <- VariableList(list())",curEnv);
        SimDat.execute("facList <- VariableList(list())",curEnv);
        SimDat.execute("numList <- VariableList(list())",curEnv);
    }

    public void makeFamily() {
        SimDat.execute("fam <- .SimDatGetDistributionFromName(\"" + famEditor.getModel().getSelectedItem().toString() + "\")", curEnv);
    }

    public void refresh() {
        if(sDependent) depEditor.refresh();
        if(sFactor) facEditor.refresh();
        if(sNumeric) numEditor.refresh();
        //famEditor.refresh();
    }
}
