namespace SmartDas.POPUP
{
    partial class POP_WRK81
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
            this.txtIND_BCD = new System.Windows.Forms.TextBox();
            this.lblIND_BCD = new SmartDas.Components.MESLabel();
            this.btnConfirm = new SmartDas.Components.MESButton();
            this.lblStatus = new SmartDas.Components.MESLabel();
            this.labTitle = new SmartDas.Components.MESLabel();
            this.btnClose = new SmartDas.Components.MESButton();
            this.lblItemInfo3 = new SmartDas.Components.MESLabel();
            this.lblItemInfo2 = new SmartDas.Components.MESLabel();
            this.lblItemInfo = new SmartDas.Components.MESLabel();
            this.lblBarcode = new SmartDas.Components.MESLabel();
            this.SuspendLayout();
            // 
            // txtIND_BCD
            // 
            this.txtIND_BCD.Font = new System.Drawing.Font("맑은 고딕", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtIND_BCD.Location = new System.Drawing.Point(154, 71);
            this.txtIND_BCD.MaxLength = 15;
            this.txtIND_BCD.Name = "txtIND_BCD";
            this.txtIND_BCD.Size = new System.Drawing.Size(356, 35);
            this.txtIND_BCD.TabIndex = 170;
            this.txtIND_BCD.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            this.txtIND_BCD.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.txtIND_BCD_KeyPress);
            // 
            // lblIND_BCD
            // 
            this.lblIND_BCD.BackColor = System.Drawing.Color.White;
            this.lblIND_BCD.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblIND_BCD.ColorContent = System.Drawing.Color.Transparent;
            this.lblIND_BCD.ColorLabel = System.Drawing.Color.White;
            this.lblIND_BCD.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblIND_BCD.Font = new System.Drawing.Font("맑은 고딕", 16F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblIND_BCD.LabelPadding = new System.Drawing.Size(10, 0);
            this.lblIND_BCD.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblIND_BCD.Location = new System.Drawing.Point(14, 777);
            this.lblIND_BCD.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblIND_BCD.MoveControl = null;
            this.lblIND_BCD.Name = "lblIND_BCD";
            this.lblIND_BCD.Size = new System.Drawing.Size(104, 38);
            this.lblIND_BCD.TabIndex = 169;
            this.lblIND_BCD.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblIND_BCD.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblIND_BCD.Visible = false;
            // 
            // btnConfirm
            // 
            this.btnConfirm.AlarmColor = System.Drawing.Color.IndianRed;
            this.btnConfirm.BackColor = System.Drawing.Color.Transparent;
            this.btnConfirm.BackGradientStyle = Infragistics.Win.GradientStyle.None;
            this.btnConfirm.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnConfirm.ButtonClickType = SmartDas.Components.MESButton.ButtonClickTypeEnum.Click;
            this.btnConfirm.ButtonPressed = false;
            this.btnConfirm.ClickBackColor = System.Drawing.Color.Yellow;
            this.btnConfirm.DownPic = null;
            this.btnConfirm.ExTag = null;
            this.btnConfirm.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold);
            this.btnConfirm.FontSize = 14F;
            this.btnConfirm.LinkButtonBox = null;
            this.btnConfirm.LinkDatePicker = null;
            this.btnConfirm.LinkGrid = null;
            this.btnConfirm.LinkMoveSize = 0;
            this.btnConfirm.LinkType = SmartDas.Components.MESButton.LinkGridButtonType.Up;
            this.btnConfirm.Location = new System.Drawing.Point(365, 758);
            this.btnConfirm.Margin = new System.Windows.Forms.Padding(0);
            this.btnConfirm.MaximumSize = new System.Drawing.Size(300, 300);
            this.btnConfirm.Name = "btnConfirm";
            this.btnConfirm.Padding = new System.Windows.Forms.Padding(0, 0, 5, 0);
            this.btnConfirm.ParentBox = null;
            this.btnConfirm.Size = new System.Drawing.Size(145, 78);
            this.btnConfirm.TabIndex = 158;
            this.btnConfirm.Text = "재단투입";
            this.btnConfirm.TextHAlign = Infragistics.Win.HAlign.Center;
            this.btnConfirm.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.btnConfirm.UpPic = null;
            this.btnConfirm.UseFlag = true;
            this.btnConfirm.Click += new System.EventHandler(this.btnConfirm_Click);
            // 
            // lblStatus
            // 
            this.lblStatus.BackColor = System.Drawing.Color.Black;
            this.lblStatus.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblStatus.ColorContent = System.Drawing.Color.Transparent;
            this.lblStatus.ColorLabel = System.Drawing.Color.Black;
            this.lblStatus.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblStatus.Font = new System.Drawing.Font("맑은 고딕", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblStatus.ForeColor = System.Drawing.Color.Yellow;
            this.lblStatus.LabelPadding = new System.Drawing.Size(5, 0);
            this.lblStatus.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblStatus.Location = new System.Drawing.Point(5, 684);
            this.lblStatus.Margin = new System.Windows.Forms.Padding(4, 5, 4, 5);
            this.lblStatus.MoveControl = null;
            this.lblStatus.Name = "lblStatus";
            this.lblStatus.Size = new System.Drawing.Size(652, 69);
            this.lblStatus.TabIndex = 157;
            this.lblStatus.Text = "투입호기 :";
            this.lblStatus.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblStatus.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // labTitle
            // 
            this.labTitle.BackColor = System.Drawing.Color.RoyalBlue;
            this.labTitle.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.labTitle.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.labTitle.ColorContent = System.Drawing.Color.Transparent;
            this.labTitle.ColorLabel = System.Drawing.Color.RoyalBlue;
            this.labTitle.ColorReadOnly = System.Drawing.Color.Transparent;
            this.labTitle.Font = new System.Drawing.Font("맑은 고딕", 24F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.labTitle.ForeColor = System.Drawing.Color.White;
            this.labTitle.LabelPadding = new System.Drawing.Size(0, 0);
            this.labTitle.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.labTitle.Location = new System.Drawing.Point(5, 5);
            this.labTitle.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.labTitle.MoveControl = this;
            this.labTitle.Name = "labTitle";
            this.labTitle.Size = new System.Drawing.Size(652, 59);
            this.labTitle.TabIndex = 4;
            this.labTitle.Text = "재단대기 상세정보";
            this.labTitle.TextHAlign = Infragistics.Win.HAlign.Center;
            this.labTitle.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // btnClose
            // 
            this.btnClose.AlarmColor = System.Drawing.Color.IndianRed;
            this.btnClose.BackColor = System.Drawing.Color.Transparent;
            this.btnClose.BackGradientStyle = Infragistics.Win.GradientStyle.None;
            this.btnClose.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnClose.ButtonClickType = SmartDas.Components.MESButton.ButtonClickTypeEnum.Click;
            this.btnClose.ButtonPressed = false;
            this.btnClose.ClickBackColor = System.Drawing.Color.Yellow;
            this.btnClose.DownPic = null;
            this.btnClose.ExTag = null;
            this.btnClose.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold);
            this.btnClose.FontSize = 14F;
            this.btnClose.LinkButtonBox = null;
            this.btnClose.LinkDatePicker = null;
            this.btnClose.LinkGrid = null;
            this.btnClose.LinkMoveSize = 0;
            this.btnClose.LinkType = SmartDas.Components.MESButton.LinkGridButtonType.Up;
            this.btnClose.Location = new System.Drawing.Point(510, 758);
            this.btnClose.Margin = new System.Windows.Forms.Padding(0);
            this.btnClose.MaximumSize = new System.Drawing.Size(300, 300);
            this.btnClose.Name = "btnClose";
            this.btnClose.Padding = new System.Windows.Forms.Padding(5, 0, 0, 0);
            this.btnClose.ParentBox = null;
            this.btnClose.Size = new System.Drawing.Size(145, 78);
            this.btnClose.TabIndex = 156;
            this.btnClose.Text = "닫기";
            this.btnClose.TextHAlign = Infragistics.Win.HAlign.Center;
            this.btnClose.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.btnClose.UpPic = null;
            this.btnClose.UseFlag = true;
            this.btnClose.Click += new System.EventHandler(this.btnClose_Click);
            // 
            // lblItemInfo3
            // 
            this.lblItemInfo3.BackColor = System.Drawing.Color.LightSteelBlue;
            this.lblItemInfo3.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblItemInfo3.ColorContent = System.Drawing.Color.Transparent;
            this.lblItemInfo3.ColorLabel = System.Drawing.Color.LightSteelBlue;
            this.lblItemInfo3.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblItemInfo3.Font = new System.Drawing.Font("맑은 고딕", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblItemInfo3.LabelPadding = new System.Drawing.Size(5, 0);
            this.lblItemInfo3.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblItemInfo3.Location = new System.Drawing.Point(5, 455);
            this.lblItemInfo3.Margin = new System.Windows.Forms.Padding(4, 5, 4, 5);
            this.lblItemInfo3.MoveControl = null;
            this.lblItemInfo3.Name = "lblItemInfo3";
            this.lblItemInfo3.Size = new System.Drawing.Size(652, 228);
            this.lblItemInfo3.TabIndex = 160;
            this.lblItemInfo3.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblItemInfo3.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblItemInfo2
            // 
            this.lblItemInfo2.BackColor = System.Drawing.Color.LightGray;
            this.lblItemInfo2.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblItemInfo2.ColorContent = System.Drawing.Color.Transparent;
            this.lblItemInfo2.ColorLabel = System.Drawing.Color.LightGray;
            this.lblItemInfo2.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblItemInfo2.Font = new System.Drawing.Font("맑은 고딕", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblItemInfo2.LabelPadding = new System.Drawing.Size(5, 0);
            this.lblItemInfo2.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblItemInfo2.Location = new System.Drawing.Point(5, 316);
            this.lblItemInfo2.Margin = new System.Windows.Forms.Padding(4, 5, 4, 5);
            this.lblItemInfo2.MoveControl = null;
            this.lblItemInfo2.Name = "lblItemInfo2";
            this.lblItemInfo2.Size = new System.Drawing.Size(652, 139);
            this.lblItemInfo2.TabIndex = 159;
            this.lblItemInfo2.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblItemInfo2.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblItemInfo
            // 
            this.lblItemInfo.BackColor = System.Drawing.Color.LightSteelBlue;
            this.lblItemInfo.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblItemInfo.ColorContent = System.Drawing.Color.Transparent;
            this.lblItemInfo.ColorLabel = System.Drawing.Color.LightSteelBlue;
            this.lblItemInfo.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblItemInfo.Font = new System.Drawing.Font("맑은 고딕", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblItemInfo.LabelPadding = new System.Drawing.Size(5, 0);
            this.lblItemInfo.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblItemInfo.Location = new System.Drawing.Point(5, 112);
            this.lblItemInfo.Margin = new System.Windows.Forms.Padding(4, 5, 4, 5);
            this.lblItemInfo.MoveControl = null;
            this.lblItemInfo.Name = "lblItemInfo";
            this.lblItemInfo.Size = new System.Drawing.Size(652, 204);
            this.lblItemInfo.TabIndex = 141;
            this.lblItemInfo.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblItemInfo.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblBarcode
            // 
            this.lblBarcode.BackColor = System.Drawing.Color.LightGray;
            this.lblBarcode.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblBarcode.ColorContent = System.Drawing.Color.Transparent;
            this.lblBarcode.ColorLabel = System.Drawing.Color.LightGray;
            this.lblBarcode.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblBarcode.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblBarcode.LabelPadding = new System.Drawing.Size(60, 0);
            this.lblBarcode.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblBarcode.Location = new System.Drawing.Point(5, 63);
            this.lblBarcode.Margin = new System.Windows.Forms.Padding(4, 5, 4, 5);
            this.lblBarcode.MoveControl = null;
            this.lblBarcode.Name = "lblBarcode";
            this.lblBarcode.Size = new System.Drawing.Size(652, 51);
            this.lblBarcode.TabIndex = 168;
            this.lblBarcode.Text = "바코드";
            this.lblBarcode.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblBarcode.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // POP_WRK81
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.WhiteSmoke;
            this.ClientSize = new System.Drawing.Size(664, 843);
            this.ControlBox = false;
            this.Controls.Add(this.txtIND_BCD);
            this.Controls.Add(this.lblIND_BCD);
            this.Controls.Add(this.btnConfirm);
            this.Controls.Add(this.lblStatus);
            this.Controls.Add(this.labTitle);
            this.Controls.Add(this.btnClose);
            this.Controls.Add(this.lblItemInfo3);
            this.Controls.Add(this.lblItemInfo2);
            this.Controls.Add(this.lblItemInfo);
            this.Controls.Add(this.lblBarcode);
            this.Font = new System.Drawing.Font("굴림", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "POP_WRK81";
            this.ShowIcon = false;
            this.ShowInTaskbar = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Load += new System.EventHandler(this.POP_WRK81_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private Components.MESLabel labTitle;
        private Components.MESLabel lblItemInfo;
        private Components.MESButton btnClose;
        private Components.MESLabel lblStatus;
        private Components.MESLabel lblItemInfo3;
        private Components.MESLabel lblItemInfo2;
        private Components.MESLabel lblBarcode;
        private Components.MESButton btnConfirm;
        private Components.MESLabel lblIND_BCD;
        private System.Windows.Forms.TextBox txtIND_BCD;
    }
}