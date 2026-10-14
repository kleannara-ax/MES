namespace SmartDas.POPUP
{
    partial class MessageForm
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
            this.btnBox = new SmartDas.Components.ButtonBox();
            this.txtMessage = new SmartDas.Components.MESLabel();
            this.lblTitle = new SmartDas.Components.MESLabel();
            this.SuspendLayout();
            // 
            // btnBox
            // 
            this.btnBox.BackColor = System.Drawing.Color.Transparent;
            this.btnBox.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.btnBox.ButtonBoxType = SmartDas.Components.ButtonBox.ButtonBoxTypeEnum.Buttons;
            this.btnBox.CountX = 1;
            this.btnBox.CountY = 1;
            this.btnBox.CurrentPage = 0;
            this.btnBox.ExTag = "";
            this.btnBox.Font = new System.Drawing.Font("맑은 고딕", 25F, System.Drawing.FontStyle.Bold);
            this.btnBox.FontSize = 25F;
            this.btnBox.Location = new System.Drawing.Point(703, 510);
            this.btnBox.MarginIn = new System.Windows.Forms.Padding(3);
            this.btnBox.MarginOut = new System.Windows.Forms.Padding(3);
            this.btnBox.Name = "btnBox";
            this.btnBox.SelectCommand = null;
            this.btnBox.SelectionMode = SmartDas.Components.ButtonBox.SelectionModeEnum.Single;
            this.btnBox.SelectProcedureName = null;
            this.btnBox.Size = new System.Drawing.Size(336, 95);
            this.btnBox.TabIndex = 2;
            this.btnBox.buttonClickEvent += new SmartDas.Components.ButtonBox.ButtonClick(this.btnBox_buttonClickEvent);
            // 
            // txtMessage
            // 
            this.txtMessage.BackColor = System.Drawing.Color.Transparent;
            this.txtMessage.BackGradientStyle = Infragistics.Win.GradientStyle.None;
            this.txtMessage.ColorContent = System.Drawing.Color.Transparent;
            this.txtMessage.ColorLabel = System.Drawing.Color.LightGreen;
            this.txtMessage.ColorReadOnly = System.Drawing.Color.Transparent;
            this.txtMessage.Font = new System.Drawing.Font("맑은 고딕", 24F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtMessage.LabelPadding = new System.Drawing.Size(0, 0);
            this.txtMessage.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Content;
            this.txtMessage.Location = new System.Drawing.Point(14, 92);
            this.txtMessage.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.txtMessage.MoveControl = null;
            this.txtMessage.Name = "txtMessage";
            this.txtMessage.Size = new System.Drawing.Size(1025, 409);
            this.txtMessage.TabIndex = 1;
            this.txtMessage.TextHAlign = Infragistics.Win.HAlign.Center;
            this.txtMessage.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblTitle
            // 
            this.lblTitle.BackColor = System.Drawing.Color.RoyalBlue;
            this.lblTitle.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblTitle.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.lblTitle.ColorContent = System.Drawing.Color.Transparent;
            this.lblTitle.ColorLabel = System.Drawing.Color.RoyalBlue;
            this.lblTitle.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblTitle.Font = new System.Drawing.Font("맑은 고딕", 24F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblTitle.ForeColor = System.Drawing.Color.White;
            this.lblTitle.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblTitle.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblTitle.Location = new System.Drawing.Point(14, 15);
            this.lblTitle.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblTitle.MoveControl = this;
            this.lblTitle.Name = "lblTitle";
            this.lblTitle.Size = new System.Drawing.Size(1025, 65);
            this.lblTitle.TabIndex = 0;
            this.lblTitle.Text = "알     림";
            this.lblTitle.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblTitle.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // MessageForm
            // 
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
            this.BackColor = System.Drawing.Color.White;
            this.BackgroundImage = global::SmartDas.Properties.Resources.back;
            this.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.ClientSize = new System.Drawing.Size(1053, 617);
            this.ControlBox = false;
            this.Controls.Add(this.btnBox);
            this.Controls.Add(this.txtMessage);
            this.Controls.Add(this.lblTitle);
            this.DoubleBuffered = true;
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            this.Name = "MessageForm";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "MessageForm";
            this.ResumeLayout(false);

        }

        #endregion

        private Components.MESLabel lblTitle;
        private Components.MESLabel txtMessage;
        private Components.ButtonBox btnBox;
    }
}