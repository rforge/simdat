/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package simdat.wizards;

import java.util.ArrayList;

import simdat.SimDat;

import simdat.toolkit.VariableSelector;

import simdat.toolkit.DJList;
import simdat.toolkit.SingletonDJList;
import simdat.toolkit.SingletonAddRemoveButton;
import simdat.toolkit.AddButton;
import simdat.toolkit.RemoveButton;
import simdat.toolkit.ModelList;
import simdat.toolkit.DistributionList;

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import javax.swing.border.*;

import org.rosuda.REngine.REXPLogical;
import org.rosuda.REngine.REXP;

import org.rosuda.JGR.robjects.*;
import org.rosuda.JGR.util.ErrorMsg;
//import org.rosuda.deducer.toolkit.DJList;


/**
 *
 * @author maarten
 */
public class GLMDialog extends JPanel implements ActionListener {
    // Variables declaration - do not modify

    private static String subEnv = "GLMDialog";
    private String baseEnv = SimDat.guiEnv;
    private String curEnv = baseEnv + "$" + subEnv;
    private String rModelName;
    
    private JPanel contentPanel;

    //private
    //private JComboBox modelComboBox;
    //private DefaultComboBoxModel modelComboBoxModel;

    private ModelList modelList;
    private JPanel modelPanel;

    private JPanel depButtonPanel;
    private SingletonAddRemoveButton depAddRemoveButton;

    private SingletonDJList depList;
    private SingletonAddRemoveButton depButton;
    private javax.swing.JPanel depPanel;

    private DistributionList distBox;
    private javax.swing.JPanel distPanel;

    private JPanel facButtonPanel;
    private AddButton facAddButton;
    private RemoveButton facRemoveButton;

    private DJList facList;
    private javax.swing.JPanel facPanel;
    private javax.swing.JScrollPane facScrollPane;

    private JPanel numButtonPanel;
    private AddButton numAddButton;
    private RemoveButton numRemoveButton;

    private DJList numList;
    private javax.swing.JPanel numPanel;
    private javax.swing.JScrollPane numScrollPane;
    //private javax.swing.JScrollPane depScrollPane;

    //private
    private VariableSelector varSelector;
    
    //private javax.swing.JList varList;
    //private javax.swing.JPanel varPanel;
    //private javax.swing.JScrollPane varScrollPane;

    private Boolean showModelList;
    private Boolean showFactor;
    private Boolean showNumeric;
    private Boolean showDistribution;
    
    // End of variables declaration


    public GLMDialog() {
        new GLMDialog(true,true,true,rModelName,curEnv);
    }

    //public GLMDialog(Boolean ShowFactor, Boolean ShowNumeric, Boolean ShowDistribution, Boolean ShowModelList, String rModelName, String subEnv) {
    public GLMDialog(Boolean ShowFactor, Boolean ShowNumeric, Boolean ShowDistribution, String rModelName, String curEnv) {
        this.showFactor = ShowFactor;
        this.showNumeric = ShowNumeric;
        this.showDistribution = ShowDistribution;
        //this.showModelList = ShowModelList;
        this.curEnv = curEnv;
        //this.curEnv = SimDat.guiEnv + "$" + subEnv;
        this.rModelName = rModelName;

        // TODO: if model doesn't exist, throw error!
        if (((REXPLogical) SimDat.eval("!exists('" + rModelName + "')",curEnv)).isTRUE()[0]) {
                SimDat.eval(rModelName + "<- new(\"SimDatModel\")",curEnv);
        }
        /*
        if (rModelName != null) {
            SimDat.setRecentModel(rModelName);
            if(showModelList) {
                modelList.refreshModelNames();
                modelList.setSelectedItem(rModelName);
            }       
        }
         * 
         */
        
        
       //contentPanel.setBorder(new EmptyBorder(new Insets(10, 10, 10, 10)));

        //modelList = new ModelList();
        //modelList = new ModelList();
        //modelList.addActionListener(this);

        setLayout(new java.awt.BorderLayout(5,5));

        /*
        if(showModelList) {
            modelPanel = new JPanel();
            modelPanel.setLayout(new GridLayout(1,1));
            modelPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Use model:"));
            modelPanel.add(modelList);
                    
            add(modelPanel, BorderLayout.NORTH);
        }

         * 
         */

        contentPanel = getContentPanel();
        add(contentPanel, BorderLayout.CENTER);
        //contentPanel.setLayout(new java.awt.BorderLayout());
        
        
    }
    private JPanel getContentPanel() {

        //JPanel contentPanel1 = new JPanel();
        JPanel jPanel1 = new JPanel();
        jPanel1.setLayout(new GridBagLayout());
        //jPanel1.setMinimumSize(new Dimension(800,800));
        
        GridBagConstraints cstr = new GridBagConstraints();
        cstr.insets = new Insets(5, 5, 5, 5);

        //String currentMod = ((RObject)modelList.getSelectedItem()).getName();
        String currentMod = rModelName;
        varSelector = new VariableSelector(currentMod,curEnv);

        //varPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Variables"));
        //varScrollPane = new javax.swing.JScrollPane();
        //varList = new javax.swing.JList();

        depPanel = new javax.swing.JPanel();
        depPanel.setLayout(new GridLayout(1,1));
        depPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Dependent"));
        depPanel.setMinimumSize(new Dimension(10,50));
        //depScrollPane = new javax.swing.JScrollPane();
        depList = new SingletonDJList();
        ListModel depModel = new DefaultListModel();
        depList.setModel(depModel);
        depPanel.add(depList);

        depAddRemoveButton = new SingletonAddRemoveButton(
            new String[]{"Add Outcome","Remove Outcome"},
            new String[]{"Add Outcome","Remove Outcome"},
            depList,varSelector);

        depButtonPanel = new JPanel();
        depButtonPanel.setLayout(new java.awt.BorderLayout());
        depButtonPanel.add(depAddRemoveButton, java.awt.BorderLayout.CENTER);
        
        facPanel = new javax.swing.JPanel();
        facPanel.setLayout(new GridLayout(1,1));
        facPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Factor(s)"));
        facScrollPane = new javax.swing.JScrollPane();
        facList = new DJList();
        facScrollPane.setViewportView(facList);
        facPanel.add(facScrollPane);

        facButtonPanel = new JPanel();
        facButtonPanel.setLayout(new BoxLayout(facButtonPanel, BoxLayout.Y_AXIS));
        facAddButton = new AddButton("Add Factor",varSelector,facList);
        facRemoveButton = new RemoveButton("Remove Factor",varSelector,facList);
        facButtonPanel.add(facAddButton);
        facButtonPanel.add(facRemoveButton);

        numPanel = new javax.swing.JPanel();
        numPanel.setLayout(new GridLayout(1,1));
        numPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Numeric(s)"));
        numScrollPane = new javax.swing.JScrollPane();
        numList = new DJList();
        numScrollPane.setViewportView(numList);
        numPanel.add(numScrollPane);

        numButtonPanel = new JPanel();
        numButtonPanel.setLayout(new BoxLayout(numButtonPanel, BoxLayout.Y_AXIS));
        numAddButton = new AddButton("Add Numeric",varSelector,numList);
        numRemoveButton = new RemoveButton("Remove Numeric",varSelector,numList);
        numButtonPanel.add(numAddButton);
        numButtonPanel.add(numRemoveButton);

        distPanel = new javax.swing.JPanel();
        distPanel.setLayout(new GridLayout(1,1));
        distPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Distribution(s)"));
        distBox = new DistributionList();
        distPanel.add(distBox);

        int rows = 1; // dependent
        if(this.showFactor) {
            rows += 1;
        }

        if(this.showNumeric) {
            rows += 1;
        }

        if(this.showDistribution) {
            rows += 1;
        }

        //contentPanel1.setLayout(new java.awt.BorderLayout());
        

        cstr.fill = GridBagConstraints.BOTH;
        cstr.gridx = 0;
        cstr.gridy = 0;
        cstr.weightx = 1;
        cstr.weighty = 1;
        cstr.gridheight = rows;
        cstr.gridwidth = 1;
        jPanel1.add(varSelector, cstr);
        
        //
        
        //
        cstr.fill = GridBagConstraints.BOTH;
        cstr.gridx = 2;
        cstr.gridy = 0;
        cstr.weightx = 1;
        cstr.gridheight = 1;
        jPanel1.add(depPanel, cstr);

        cstr.fill = GridBagConstraints.NONE;
        cstr.gridx = 1;
        //cstr.gridy = 0;
        cstr.weightx = 0;
        //cstr.gridheight = 1;
        jPanel1.add(depButtonPanel, cstr);


        int ypos = 1;
        if(this.showFactor) {
            cstr.fill = GridBagConstraints.BOTH;
            cstr.gridx = 2;
            cstr.gridy = ypos;
            cstr.weightx = 1;
            cstr.gridheight = 1;
            jPanel1.add(facPanel, cstr);

            cstr.fill = GridBagConstraints.NONE;
            cstr.gridx = 1;
            cstr.weightx = 0;
            jPanel1.add(facButtonPanel, cstr);

            ypos += 1;
        }

        if(this.showNumeric) {
            cstr.fill = GridBagConstraints.BOTH;
            cstr.gridx = 2;
            cstr.gridy = ypos;
            cstr.weightx = 1;
            cstr.gridheight = 1;
            jPanel1.add(numPanel, cstr);

            cstr.fill = GridBagConstraints.NONE;
            cstr.gridx = 1;
            cstr.weightx = 0;
            jPanel1.add(numButtonPanel, cstr);

            ypos += 1;
        }

        if(this.showDistribution) {
            cstr.fill = GridBagConstraints.HORIZONTAL;
            cstr.gridx = 2;
            cstr.gridy = ypos;
            cstr.weightx = 1;
            cstr.gridheight = 1;
            jPanel1.add(distPanel, cstr);

            ypos += 1;
        }

        return jPanel1;

        //contentPanel1.setLayout(new java.awt.BorderLayout());
        //contentPanel1.setLayout(new GridLayout(1,1));
        //contentPanel1.add(jPanel1);
        //return contentPanel1;
    }

    	
    /*
        public void setSelectedModel(String modelName){
            //modelList.setSelectedItem(modelName);
            rModelName = modelName;
	}
     * 
     */

        /*
        public String getSelectedModel(){
		return (String)modelList.getSelectedItem();
	}
         * 
         */

    public void reset(){
        //this.varSelector.reset((String)modelList.getSelectedItem());
        this.varSelector.reset(rModelName);
        this.facList = new DJList();
        this.numList = new DJList();
        this.depList = new SingletonDJList();
    }

    public void keyPressed(KeyEvent e) {}
    public void keyReleased(KeyEvent e) {}

    public Boolean hasDependent() {
        Boolean out = false;
        if(this.depList.getModel().getSize() > 0)
            out = true;
        return out;
    }

    public String getDependent() {
        //String[] ls = new String[depList.getModel().getSize()];
        //for(int i = 0; i < ls.length; i++) {
        //    ls[i] = depList.getModel().getElementAt(i).toString();
        //}
        return depList.getModel().getElementAt(0).toString();
    }
    
    public Boolean hasDistribution() {
        Boolean out = false;
        if(this.distBox.getSelectedObjects().length > 0)
            out = true;
        return out;
    }
    public String getDistribution() {
        return this.distBox.getModel().getSelectedItem().toString();
    }
    public Boolean hasFactor() {
        Boolean out = false;
        if(this.facList.getModel().getSize() > 0)
            out = true;
        return out;
    }
    public String[] getFactor() {
        String[] ls = new String[facList.getModel().getSize()];
        for(int i = 0; i < ls.length; i++) {
            ls[i] = facList.getModel().getElementAt(i).toString();
        }
        return ls;
    }
    public Boolean hasNumeric() {
        Boolean out = false;
        if(this.numList.getModel().getSize() > 0)
            out = true;
        return out;
    }
    public String[] getNumeric() {
        String[] ls = new String[numList.getModel().getSize()];
        for(int i = 0; i < ls.length; i++) {
            ls[i] = numList.getModel().getElementAt(i).toString();
        }
        return ls;
    }

    public String getModelName() {
        /*
        int i = modelList.getSelectedIndex();
        String ls = ((RObject) SimDat.getModels().elementAt(i)).getName();
        return ls;
         *
         */
        return rModelName;
    }
    // TODO: need to set unique event for model selection changed
    
    public void actionPerformed(ActionEvent arg0) {
        String cmd = arg0.getActionCommand();
	//if(cmd=="comboBoxChanged"){
        //    this.reset();
        //}

    }

    public Boolean oldMakeRdf(String rObjectName) {
            String cmd = "arglist <- list(); ";

            if(this.hasDependent()) {
                cmd += "arglist[[\"dep\"]] <- variables(" + this.getModelName();
                cmd += ",\"" + this.getDependent() + "\"); "; // TODO: get rid of [[1]]
            } else {

            }
            if(this.hasFactor()) {
                String[] fac = this.getFactor();
                //if(fac.length > 1) {
                cmd += "arglist[[\"fac\"]] <- variables(";
                cmd += this.getModelName() + ",c(";
                for(int i = 0; i < fac.length - 1; i++) {
                    cmd += "\"" + fac[i] + "\",";
                }
                cmd += "\"" + fac[fac.length - 1] + "\")); ";
                //} else {
                //    cmd += "arglist[\"fac\"] <- VariableList(list(variables(";
                //    cmd += this.getModelName() + ")[[" + fac[0] + "]]"
                //    cmd += this.getModelName() + ")) %in% c(";
                //}
            } else {

            }
            if(this.hasNumeric()) {
                String[] num = this.getNumeric();
                cmd += "arglist[[\"num\"]] <- variables(";
                cmd += this.getModelName() + ",c(";
                for(int i = 0; i < num.length - 1; i++) {
                    cmd += "\"" + num[i] + "\",";
                }
                cmd += "\"" + num[num.length - 1] + "\")); ";
            } else {

            }
            if(this.hasDistribution()) {
                cmd += "arglist[[\"family\"]] <- .SimDatGetDistributionFromName(\"" + this.getDistribution() + "\"); ";
            } else {

            }

            cmd += rObjectName + " <- do.call(\"GlmWizardDf\",args=arglist)";
            REXP result;
            try{
                result = SimDat.eval(cmd);
            } catch (Exception e) {
                new ErrorMsg(e);
            }

            Boolean ok = false;
            REXPLogical tmp = (REXPLogical) SimDat.eval("!is.null(" + rObjectName + ")");
            ok = tmp.isTRUE()[0];
            return ok;
    }

    public boolean MakeVarLists(boolean needDep, boolean needFac, boolean needNum, boolean needFam) {
        boolean ok = true;
        String cmd;
        if(this.hasDependent()) {
            cmd = "depList <- variables(" + this.getModelName() + ",\"" + this.getDependent() + "\")";
            SimDat.execute(cmd,curEnv);
            SimDat.execute("if(!is(depList,'VariableList')) depList <- VariableList(list(depList))",curEnv);
            if(needDep) {
                REXPLogical tmp = (REXPLogical) SimDat.eval("!is.null(depList)",curEnv);
            if(tmp.isFALSE()[0]) ok = false;
            }
        } else {
            SimDat.eval("depList <- VariableList(list())",curEnv);
            if(needDep) ok = false;
        }
        
        if(this.hasFactor()) {
            String[] fac = this.getFactor();
                //if(fac.length > 1) {
            cmd = "facList <- variables(";
            cmd += this.getModelName() + ",c(";
            for(int i = 0; i < fac.length - 1; i++) {
                cmd += "\"" + fac[i] + "\",";
            }
            cmd += "\"" + fac[fac.length - 1] + "\"))";


            SimDat.execute(cmd,curEnv);
            SimDat.execute("if(!is(facList,'VariableList')) facList <- VariableList(list(facList))",curEnv);
            if(needFac) {
                REXPLogical tmp = (REXPLogical) SimDat.eval("!is.null(facList)",curEnv);
                if(tmp.isFALSE()[0]) ok = false;
            }
        } else {
            SimDat.eval("facList <- VariableList(list())",curEnv);
            if(needFac) ok = false;
        }

        if(this.hasNumeric()) {
            String[] num = this.getNumeric();
                //if(fac.length > 1) {
            cmd = "numList <- variables(";
            cmd += this.getModelName() + ",c(";
            for(int i = 0; i < num.length - 1; i++) {
                cmd += "\"" + num[i] + "\",";
            }
            cmd += "\"" + num[num.length - 1] + "\"))";
            SimDat.execute(cmd,curEnv);
            cmd = "modList <- models(";
            cmd += this.getModelName() + ",c(";
            for(int i = 0; i < num.length - 1; i++) {
                cmd += "\"" + num[i] + "\",";
            }
            cmd += "\"" + num[num.length - 1] + "\"))";
            SimDat.execute(cmd,curEnv);
            SimDat.execute("if(!is(numList,'VariableList')) numList <- VariableList(list(numList))",curEnv);
            SimDat.execute("if(!is(modList,'ModelList')) modList <- ModelList(list(modList))",curEnv);
            if(needNum) {
                REXPLogical tmp = (REXPLogical) SimDat.eval("!is.null(numList)",curEnv);
                if(tmp.isFALSE()[0]) ok = false;
            }
        } else {
            SimDat.eval("numList <- VariableList(list())",curEnv);
            SimDat.eval("modList <- ModelList(list())",curEnv);
            if(needNum) ok = false;
        }

        if(this.hasDistribution()) {
            cmd = "fam <- .SimDatGetDistributionFromName(\"" + this.getDistribution() + "\")";
            SimDat.execute(cmd,curEnv);
            if(needFam) {
                REXPLogical tmp = (REXPLogical) SimDat.eval("!is.null(fam)",curEnv);
                if(tmp.isFALSE()[0]) ok = false;
            }
        } else {
            if(needNum) ok = false;
        }
        return ok;
    }

        public boolean MakeRdf(String rObjectName) {

            int ncomm = 2;
            if(this.hasDependent()) ncomm += 1;
            if(this.hasFactor()) ncomm += 1;
            if(this.hasNumeric()) ncomm += 1;
            if(this.hasDistribution()) ncomm += 1;

            String cmd[] = new String[ncomm];

            cmd[0] = "arglist <- list()";

            int count = 1;
            
            if(this.hasDependent()) {
                cmd[count] = "arglist[[\"dep\"]] <- variables(" + this.getModelName();
                cmd[count] += ",\"" + this.getDependent() + "\")"; // TODO: get rid of [[1]]
                count += 1;
            } else {

            }
            if(this.hasFactor()) {
                String[] fac = this.getFactor();
                //if(fac.length > 1) {
                cmd[count] = "arglist[[\"fac\"]] <- variables(";
                cmd[count] += this.getModelName() + ",c(";
                for(int i = 0; i < fac.length - 1; i++) {
                    cmd[count] += "\"" + fac[i] + "\",";
                }
                cmd[count] += "\"" + fac[fac.length - 1] + "\"))";
                //} else {
                //    cmd += "arglist[\"fac\"] <- VariableList(list(variables(";
                //    cmd += this.getModelName() + ")[[" + fac[0] + "]]"
                //    cmd += this.getModelName() + ")) %in% c(";
                //}
                count += 1;
            } else {

            }
            if(this.hasNumeric()) {
                String[] num = this.getNumeric();
                cmd[count] = "arglist[[\"num\"]] <- variables(";
                cmd[count] += this.getModelName() + ",c(";
                for(int i = 0; i < num.length - 1; i++) {
                    cmd[count] += "\"" + num[i] + "\",";
                }
                cmd[count] += "\"" + num[num.length - 1] + "\"))";
                count += 1;
            } else {

            }
            if(this.hasDistribution()) {
                cmd[count] = "arglist[[\"family\"]] <- .SimDatGetDistributionFromName(\"" + this.getDistribution() + "\")";
                count += 1;
            } else {

            }

            cmd[count] = rObjectName + " <- do.call(\"GlmWizardDf\",args=arglist)";
            //REXP result;
            try{
                SimDat.eval(cmd);
            } catch (Exception e) {
                new ErrorMsg(e);
            }

            Boolean ok = false;
            REXPLogical tmp = (REXPLogical) SimDat.eval("!is.null(" + rObjectName + ")");
            ok = tmp.isTRUE()[0];
            return ok;
    }

}
