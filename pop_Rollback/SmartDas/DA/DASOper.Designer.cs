namespace SmartDas
{
    partial class DASOper
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            Infragistics.Win.Appearance appearance1 = new Infragistics.Win.Appearance();
            this.txtMachName = new SmartDas.Components.MESLabel();
            this.label4 = new System.Windows.Forms.Label();
            this.bBoxOPGrp = new SmartDas.Components.ButtonBox();
            this.txtUserName = new SmartDas.Components.MESLabel();
            this.label3 = new System.Windows.Forms.Label();
            this.txtOPGrpName = new SmartDas.Components.MESLabel();
            this.label2 = new System.Windows.Forms.Label();
            this.bBox1 = new SmartDas.Components.ButtonBox();
            this.label1 = new System.Windows.Forms.Label();
            this.txtOPName = new SmartDas.Components.MESLabel();
            this.bBoxOper = new SmartDas.Components.ButtonBox();
            ((System.ComponentModel.ISupportInitialize)(this.GroupBody)).BeginInit();
            this.GroupBody.SuspendLayout();
            this.SuspendLayout();
            // 
            // lblTitle
            // 
            this.lblTitle.Text = "공정 선택";
            // 
            // GroupBody
            // 
            appearance1.BackColor = System.Drawing.Color.White;
            this.GroupBody.Appearance = appearance1;
            this.GroupBody.Controls.Add(this.bBoxOper);
            this.GroupBody.Controls.Add(this.txtMachName);
            this.GroupBody.Controls.Add(this.label4);
            this.GroupBody.Controls.Add(this.bBoxOPGrp);
            this.GroupBody.Controls.Add(this.txtUserName);
            this.GroupBody.Controls.Add(this.label3);
            this.GroupBody.Controls.Add(this.txtOPGrpName);
            this.GroupBody.Controls.Add(this.label2);
            this.GroupBody.Controls.Add(this.bBox1);
            this.GroupBody.Controls.Add(this.label1);
            this.GroupBody.Controls.Add(this.txtOPName);
            // 
            // txtMachName
            // 
            this.txtMachName.BackColor = System.Drawing.SystemColors.Control;
            this.txtMachName.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.txtMachName.ColorContent = System.Drawing.Color.Thistle;
            this.txtMachName.ColorLabel = System.Drawing.SystemColors.Control;
            this.txtMachName.ColorReadOnly = System.Drawing.Color.Transparent;
            this.txtMachName.Font = new System.Drawing.Font("맑은 고딕", 20.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtMachName.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.txtMachName.Location = new System.Drawing.Point(640, 76);
            this.txtMachName.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.txtMachName.MoveControl = null;
            this.txtMachName.Name = "txtMachName";
            this.txtMachName.Size = new System.Drawing.Size(276, 60);
            this.txtMachName.TabIndex = 66;
            this.txtMachName.TextHAlign = Infragistics.Win.HAlign.Left;
            this.txtMachName.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label4
            // 
            this.label4.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(76)))), ((int)(((byte)(121)))), ((int)(((byte)(211)))));
            this.label4.Font = new System.Drawing.Font("맑은 고딕", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label4.ForeColor = System.Drawing.Color.White;
            this.label4.Location = new System.Drawing.Point(467, 76);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(165, 60);
            this.label4.TabIndex = 65;
            this.label4.Text = "설       비";
            this.label4.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // bBoxOPGrp
            // 
            this.bBoxOPGrp.BackColor = System.Drawing.Color.Thistle;
            this.bBoxOPGrp.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.bBoxOPGrp.ButtonBoxType = SmartDas.Components.ButtonBox.ButtonBoxTypeEnum.Selection;
            this.bBoxOPGrp.CountX = 1;
            this.bBoxOPGrp.CountY = 1;
            this.bBoxOPGrp.CurrentPage = 0;
            this.bBoxOPGrp.ExTag = "";
            this.bBoxOPGrp.Font = new System.Drawing.Font("맑은 고딕", 20.25F, System.Drawing.FontStyle.Bold);
            this.bBoxOPGrp.FontSize = 20.25F;
            this.bBoxOPGrp.Location = new System.Drawing.Point(10, 142);
            this.bBoxOPGrp.MarginIn = new System.Windows.Forms.Padding(3);
            this.bBoxOPGrp.MarginOut = new System.Windows.Forms.Padding(3);
            this.bBoxOPGrp.Name = "bBoxOPGrp";
            this.bBoxOPGrp.SelectCommand = null;
            this.bBoxOPGrp.SelectionMode = SmartDas.Components.ButtonBox.SelectionModeEnum.Single;
            this.bBoxOPGrp.SelectProcedureName = null;
            this.bBoxOPGrp.Size = new System.Drawing.Size(1259, 150);
            this.bBoxOPGrp.TabIndex = 64;
            this.bBoxOPGrp.buttonChangeEvent += new SmartDas.Components.ButtonBox.ButtonChange(this.bBoxOPGrp_buttonChangeEvent);
            // 
            // txtUserName
            // 
            this.txtUserName.BackColor = System.Drawing.Color.White;
            this.txtUserName.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.txtUserName.ColorContent = System.Drawing.Color.Transparent;
            this.txtUserName.ColorLabel = System.Drawing.Color.White;
            this.txtUserName.ColorReadOnly = System.Drawing.Color.Transparent;
            this.txtUserName.Font = new System.Drawing.Font("맑은 고딕", 20.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtUserName.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.txtUserName.Location = new System.Drawing.Point(639, 10);
            this.txtUserName.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.txtUserName.MoveControl = null;
            this.txtUserName.Name = "txtUserName";
            this.txtUserName.Size = new System.Drawing.Size(275, 60);
            this.txtUserName.TabIndex = 63;
            this.txtUserName.TextHAlign = Infragistics.Win.HAlign.Left;
            this.txtUserName.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label3
            // 
            this.label3.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(76)))), ((int)(((byte)(121)))), ((int)(((byte)(211)))));
            this.label3.Font = new System.Drawing.Font("맑은 고딕", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label3.ForeColor = System.Drawing.Color.White;
            this.label3.Location = new System.Drawing.Point(466, 10);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(165, 60);
            this.label3.TabIndex = 62;
            this.label3.Text = "사 용 자";
            this.label3.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // txtOPGrpName
            // 
            this.txtOPGrpName.BackColor = System.Drawing.Color.White;
            this.txtOPGrpName.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.txtOPGrpName.ColorContent = System.Drawing.Color.Transparent;
            this.txtOPGrpName.ColorLabel = System.Drawing.Color.White;
            this.txtOPGrpName.ColorReadOnly = System.Drawing.Color.Transparent;
            this.txtOPGrpName.Font = new System.Drawing.Font("맑은 고딕", 20.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtOPGrpName.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.txtOPGrpName.Location = new System.Drawing.Point(182, 10);
            this.txtOPGrpName.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.txtOPGrpName.MoveControl = null;
            this.txtOPGrpName.Name = "txtOPGrpName";
            this.txtOPGrpName.Size = new System.Drawing.Size(276, 60);
            this.txtOPGrpName.TabIndex = 61;
            this.txtOPGrpName.TextHAlign = Infragistics.Win.HAlign.Left;
            this.txtOPGrpName.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label2
            // 
            this.label2.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(76)))), ((int)(((byte)(121)))), ((int)(((byte)(211)))));
            this.label2.Font = new System.Drawing.Font("맑은 고딕", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label2.ForeColor = System.Drawing.Color.White;
            this.label2.Location = new System.Drawing.Point(10, 10);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(165, 60);
            this.label2.TabIndex = 60;
            this.label2.Text = "공 정 그 룹";
            this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // bBox1
            // 
            this.bBox1.BackColor = System.Drawing.Color.Transparent;
            this.bBox1.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.bBox1.ButtonBoxType = SmartDas.Components.ButtonBox.ButtonBoxTypeEnum.Selection;
            this.bBox1.CountX = 1;
            this.bBox1.CountY = 1;
            this.bBox1.CurrentPage = 0;
            this.bBox1.ExTag = "";
            this.bBox1.Font = new System.Drawing.Font("맑은 고딕", 20.25F, System.Drawing.FontStyle.Bold);
            this.bBox1.FontSize = 20.25F;
            this.bBox1.Location = new System.Drawing.Point(923, 10);
            this.bBox1.MarginIn = new System.Windows.Forms.Padding(3);
            this.bBox1.MarginOut = new System.Windows.Forms.Padding(3);
            this.bBox1.Name = "bBox1";
            this.bBox1.SelectCommand = null;
            this.bBox1.SelectionMode = SmartDas.Components.ButtonBox.SelectionModeEnum.Single;
            this.bBox1.SelectProcedureName = null;
            this.bBox1.Size = new System.Drawing.Size(346, 126);
            this.bBox1.TabIndex = 59;
            this.bBox1.buttonClickEvent += new SmartDas.Components.ButtonBox.ButtonClick(this.bBox1_buttonClickEvent);
            // 
            // label1
            // 
            this.label1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(76)))), ((int)(((byte)(121)))), ((int)(((byte)(211)))));
            this.label1.Font = new System.Drawing.Font("맑은 고딕", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label1.ForeColor = System.Drawing.Color.White;
            this.label1.Location = new System.Drawing.Point(10, 76);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(165, 60);
            this.label1.TabIndex = 58;
            this.label1.Text = "공       정";
            this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // txtOPName
            // 
            this.txtOPName.BackColor = System.Drawing.Color.White;
            this.txtOPName.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.txtOPName.ColorContent = System.Drawing.Color.Transparent;
            this.txtOPName.ColorLabel = System.Drawing.Color.White;
            this.txtOPName.ColorReadOnly = System.Drawing.Color.Transparent;
            this.txtOPName.Font = new System.Drawing.Font("맑은 고딕", 20.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtOPName.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.txtOPName.Location = new System.Drawing.Point(183, 76);
            this.txtOPName.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.txtOPName.MoveControl = null;
            this.txtOPName.Name = "txtOPName";
            this.txtOPName.Size = new System.Drawing.Size(276, 60);
            this.txtOPName.TabIndex = 57;
            this.txtOPName.TextHAlign = Infragistics.Win.HAlign.Left;
            this.txtOPName.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // bBoxOper
            // 
            this.bBoxOper.BackColor = System.Drawing.SystemColors.Control;
            this.bBoxOper.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.bBoxOper.ButtonBoxType = SmartDas.Components.ButtonBox.ButtonBoxTypeEnum.Selection;
            this.bBoxOper.CountX = 1;
            this.bBoxOper.CountY = 1;
            this.bBoxOper.CurrentPage = 0;
            this.bBoxOper.ExTag = "";
            this.bBoxOper.Font = new System.Drawing.Font("맑은 고딕", 20.25F, System.Drawing.FontStyle.Bold);
            this.bBoxOper.FontSize = 20.25F;
            this.bBoxOper.Location = new System.Drawing.Point(9, 298);
            this.bBoxOper.MarginIn = new System.Windows.Forms.Padding(3);
            this.bBoxOper.MarginOut = new System.Windows.Forms.Padding(3);
            this.bBoxOper.Name = "bBoxOper";
            this.bBoxOper.SelectCommand = null;
            this.bBoxOper.SelectionMode = SmartDas.Components.ButtonBox.SelectionModeEnum.Single;
            this.bBoxOper.SelectProcedureName = null;
            this.bBoxOper.Size = new System.Drawing.Size(1259, 300);
            this.bBoxOper.TabIndex = 67;
            this.bBoxOper.buttonChangeEvent += new SmartDas.Components.ButtonBox.ButtonChange(this.bBoxOper_buttonChangeEvent);
            // 
            // DASOper
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1280, 1024);
            this.Name = "DASOper";
            this.Text = "DASOper";
            this.Load += new System.EventHandler(this.DASOper_Load);
            ((System.ComponentModel.ISupportInitialize)(this.GroupBody)).EndInit();
            this.GroupBody.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private Components.MESLabel txtMachName;
        private System.Windows.Forms.Label label4;
        private Components.ButtonBox bBoxOPGrp;
        private Components.MESLabel txtUserName;
        private System.Windows.Forms.Label label3;
        private Components.MESLabel txtOPGrpName;
        private System.Windows.Forms.Label label2;
        private Components.ButtonBox bBox1;
        private System.Windows.Forms.Label label1;
        private Components.MESLabel txtOPName;
        private Components.ButtonBox bBoxOper;
    }
}