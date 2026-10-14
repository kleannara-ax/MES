namespace SmartDas.POPUP
{
    partial class DAResultText
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
            this.txtContent = new System.Windows.Forms.TextBox();
            this.btnOK = new SmartDas.Components.MESButton();
            this.btnCancel = new SmartDas.Components.MESButton();
            this.lblTitle = new SmartDas.Components.MESLabel();
            this.SuspendLayout();
            // 
            // txtContent
            // 
            this.txtContent.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(255)))), ((int)(((byte)(192)))));
            this.txtContent.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtContent.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.txtContent.Location = new System.Drawing.Point(12, 90);
            this.txtContent.MaxLength = 100;
            this.txtContent.Name = "txtContent";
            this.txtContent.Size = new System.Drawing.Size(946, 39);
            this.txtContent.TabIndex = 161;
            this.txtContent.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.txtContent_KeyPress);
            // 
            // btnOK
            // 
            this.btnOK.AlarmColor = System.Drawing.Color.IndianRed;
            this.btnOK.BackColor = System.Drawing.Color.Transparent;
            this.btnOK.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.btnOK.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnOK.ButtonClickType = SmartDas.Components.MESButton.ButtonClickTypeEnum.Click;
            this.btnOK.ButtonPressed = false;
            this.btnOK.ClickBackColor = System.Drawing.Color.Transparent;
            this.btnOK.DownPic = null;
            this.btnOK.ExTag = null;
            this.btnOK.Font = new System.Drawing.Font("맑은 고딕", 22F, System.Drawing.FontStyle.Bold);
            this.btnOK.FontSize = 22F;
            this.btnOK.LinkButtonBox = null;
            this.btnOK.LinkDatePicker = null;
            this.btnOK.LinkGrid = null;
            this.btnOK.LinkMoveSize = 0;
            this.btnOK.LinkType = SmartDas.Components.MESButton.LinkGridButtonType.Up;
            this.btnOK.Location = new System.Drawing.Point(12, 148);
            this.btnOK.Margin = new System.Windows.Forms.Padding(8, 9, 8, 9);
            this.btnOK.Name = "btnOK";
            this.btnOK.ParentBox = null;
            this.btnOK.Size = new System.Drawing.Size(230, 60);
            this.btnOK.TabIndex = 148;
            this.btnOK.Text = "확인";
            this.btnOK.TextHAlign = Infragistics.Win.HAlign.Center;
            this.btnOK.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.btnOK.UpPic = null;
            this.btnOK.UseFlag = true;
            this.btnOK.Click += new System.EventHandler(this.btnOK_Click);
            // 
            // btnCancel
            // 
            this.btnCancel.AlarmColor = System.Drawing.Color.IndianRed;
            this.btnCancel.BackColor = System.Drawing.Color.Transparent;
            this.btnCancel.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.btnCancel.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnCancel.ButtonClickType = SmartDas.Components.MESButton.ButtonClickTypeEnum.Click;
            this.btnCancel.ButtonPressed = false;
            this.btnCancel.ClickBackColor = System.Drawing.Color.Transparent;
            this.btnCancel.DownPic = null;
            this.btnCancel.ExTag = null;
            this.btnCancel.Font = new System.Drawing.Font("맑은 고딕", 22F, System.Drawing.FontStyle.Bold);
            this.btnCancel.FontSize = 22F;
            this.btnCancel.LinkButtonBox = null;
            this.btnCancel.LinkDatePicker = null;
            this.btnCancel.LinkGrid = null;
            this.btnCancel.LinkMoveSize = 0;
            this.btnCancel.LinkType = SmartDas.Components.MESButton.LinkGridButtonType.Up;
            this.btnCancel.Location = new System.Drawing.Point(728, 148);
            this.btnCancel.Margin = new System.Windows.Forms.Padding(8, 9, 8, 9);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.ParentBox = null;
            this.btnCancel.Size = new System.Drawing.Size(230, 60);
            this.btnCancel.TabIndex = 87;
            this.btnCancel.Text = "닫기";
            this.btnCancel.TextHAlign = Infragistics.Win.HAlign.Center;
            this.btnCancel.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.btnCancel.UpPic = null;
            this.btnCancel.UseFlag = true;
            this.btnCancel.Click += new System.EventHandler(this.btnCancel_Click);
            // 
            // lblTitle
            // 
            this.lblTitle.BackColor = System.Drawing.Color.RoyalBlue;
            this.lblTitle.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblTitle.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.lblTitle.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.lblTitle.ColorContent = System.Drawing.Color.Transparent;
            this.lblTitle.ColorLabel = System.Drawing.Color.RoyalBlue;
            this.lblTitle.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblTitle.Font = new System.Drawing.Font("맑은 고딕", 25F, System.Drawing.FontStyle.Bold);
            this.lblTitle.ForeColor = System.Drawing.Color.White;
            this.lblTitle.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblTitle.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblTitle.Location = new System.Drawing.Point(12, 11);
            this.lblTitle.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblTitle.MoveControl = null;
            this.lblTitle.Name = "lblTitle";
            this.lblTitle.Size = new System.Drawing.Size(946, 60);
            this.lblTitle.TabIndex = 86;
            this.lblTitle.Text = "비고입력";
            this.lblTitle.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblTitle.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // DAResultText
            // 
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
            this.BackColor = System.Drawing.Color.WhiteSmoke;
            this.ClientSize = new System.Drawing.Size(973, 219);
            this.ControlBox = false;
            this.Controls.Add(this.txtContent);
            this.Controls.Add(this.btnOK);
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.lblTitle);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.Name = "DAResultText";
            this.ShowIcon = false;
            this.ShowInTaskbar = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Load += new System.EventHandler(this.DAResultText_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private Components.MESLabel lblTitle;
        private Components.MESButton btnCancel;
        private Components.MESButton btnOK;
        private System.Windows.Forms.TextBox txtContent;
    }
}