/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package simdat.toolkit;

import javax.swing.JPanel;
import javax.swing.JLabel;
import javax.swing.JTextField;
//import javax.swing.*;
//import javax.swing.border.*;
import java.awt.GridBagLayout;
import java.awt.GridBagConstraints;
import java.awt.Insets;

/**
 *
 * @author maarten
 */
public class NormalModelPanel extends JPanel {
    private String curEnv;
    private String rModelName;
    private String rModelId;

    private double mean;
    private double sd;

    public NormalModelPanel() {};

    public NormalModelPanel(String name, String env) {
        curEnv = env;
        rModelName = name;
    }

    private JPanel getContentPanel() {
        JPanel panel = new JPanel();
        JLabel meanLab = new JLabel();
        JLabel sdLab = new JLabel();
        JTextField meanBox = new JTextField();
        JTextField sdBox = new JTextField();
        
        panel.setLayout(new GridBagLayout());
        GridBagConstraints cstr = new GridBagConstraints();
        cstr.insets = new Insets(5, 5, 5, 5);

        cstr.fill = GridBagConstraints.BOTH;
        cstr.weightx = 1;
        cstr.weighty = 1;
        cstr.gridheight = 1;
        cstr.gridwidth = 1;

        cstr.gridx = 0;
        cstr.gridy = 0;
        panel.add(meanLab, cstr);

        cstr.gridx = 1;
        cstr.gridy = 0;
        panel.add(sdLab, cstr);

        cstr.gridx = 0;
        cstr.gridy = 1;
        panel.add(meanBox, cstr);

        cstr.gridx = 1;
        cstr.gridy = 1;
        panel.add(sdBox, cstr);

        return panel;
    }

    public double getMean() {
        return this.mean;
    }

    public void setMean(double value) {
        this.mean = value;
    }

    public double getSD() {
        return this.sd;
    }
    
    public void setSD(double value) {
        this.sd = value;
    }

}
