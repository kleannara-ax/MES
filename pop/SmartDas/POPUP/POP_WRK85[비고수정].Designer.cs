namespace SmartDas.POPUP
{
    partial class POP_WRK85
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
            this.label2 = new System.Windows.Forms.Label();
            this.label1 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.panel1 = new System.Windows.Forms.Panel();
            this.rbtnAppend = new System.Windows.Forms.RadioButton();
            this.rbtnModify = new System.Windows.Forms.RadioButton();
            this.label5 = new System.Windows.Forms.Label();
            this.lbInfo = new System.Windows.Forms.Label();
            this.txtContent = new System.Windows.Forms.TextBox();
            this.lblLotNo = new SmartDas.Components.MESLabel();
            this.lblIndBarCode = new SmartDas.Components.MESLabel();
            this.btnOK = new SmartDas.Components.MESButton();
            this.lblBeforeChange = new SmartDas.Components.MESLabel();
            this.btnCancel = new SmartDas.Components.MESButton();
            this.lblTitle = new SmartDas.Components.MESLabel();
            this.SuspendLayout();
            // 
            // label2
            // 
            this.label2.BackColor = System.Drawing.Color.Gray;
            this.label2.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label2.ForeColor = System.Drawing.Color.White;
            this.label2.Location = new System.Drawing.Point(12, 144);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(144, 40);
            this.label2.TabIndex = 149;
            this.label2.Text = "변경전 비고";
            this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label1
            // 
            this.label1.BackColor = System.Drawing.Color.Gray;
            this.label1.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label1.ForeColor = System.Drawing.Color.White;
            this.label1.Location = new System.Drawing.Point(12, 251);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(144, 40);
            this.label1.TabIndex = 150;
            this.label1.Text = "변경후 비고";
            this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label3
            // 
            this.label3.BackColor = System.Drawing.Color.Gray;
            this.label3.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label3.ForeColor = System.Drawing.Color.White;
            this.label3.Location = new System.Drawing.Point(12, 82);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(144, 40);
            this.label3.TabIndex = 152;
            this.label3.Text = "바코드";
            this.label3.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label4
            // 
            this.label4.BackColor = System.Drawing.Color.Gray;
            this.label4.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label4.ForeColor = System.Drawing.Color.White;
            this.label4.Location = new System.Drawing.Point(392, 82);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(120, 40);
            this.label4.TabIndex = 154;
            this.label4.Text = "LOT 번호";
            this.label4.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // panel1
            // 
            this.panel1.BackColor = System.Drawing.Color.Black;
            this.panel1.Location = new System.Drawing.Point(8, 229);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(950, 4);
            this.panel1.TabIndex = 156;
            // 
            // rbtnAppend
            // 
            this.rbtnAppend.AutoSize = true;
            this.rbtnAppend.Checked = true;
            this.rbtnAppend.Font = new System.Drawing.Font("맑은 고딕", 14.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.rbtnAppend.Location = new System.Drawing.Point(192, 257);
            this.rbtnAppend.Name = "rbtnAppend";
            this.rbtnAppend.Size = new System.Drawing.Size(132, 29);
            this.rbtnAppend.TabIndex = 157;
            this.rbtnAppend.TabStop = true;
            this.rbtnAppend.Text = "이어서 쓰기";
            this.rbtnAppend.UseVisualStyleBackColor = true;
            this.rbtnAppend.CheckedChanged += new System.EventHandler(this.rbtnAppend_CheckedChanged);
            // 
            // rbtnModify
            // 
            this.rbtnModify.AutoSize = true;
            this.rbtnModify.Font = new System.Drawing.Font("맑은 고딕", 14.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.rbtnModify.Location = new System.Drawing.Point(347, 257);
            this.rbtnModify.Name = "rbtnModify";
            this.rbtnModify.Size = new System.Drawing.Size(106, 29);
            this.rbtnModify.TabIndex = 158;
            this.rbtnModify.Text = "덮어쓰기";
            this.rbtnModify.UseVisualStyleBackColor = true;
            this.rbtnModify.CheckedChanged += new System.EventHandler(this.rbtnModify_CheckedChanged);
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Font = new System.Drawing.Font("맑은 고딕", 14.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label5.Location = new System.Drawing.Point(701, 90);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(247, 25);
            this.label5.TabIndex = 159;
            this.label5.Text = "의 비고내용을 변경 합니다.";
            // 
            // lbInfo
            // 
            this.lbInfo.BackColor = System.Drawing.Color.WhiteSmoke;
            this.lbInfo.Font = new System.Drawing.Font("맑은 고딕", 14.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lbInfo.ForeColor = System.Drawing.Color.DarkRed;
            this.lbInfo.Location = new System.Drawing.Point(486, 257);
            this.lbInfo.Name = "lbInfo";
            this.lbInfo.Size = new System.Drawing.Size(472, 25);
            this.lbInfo.TabIndex = 160;
            this.lbInfo.Text = "변경전 비고에 추가할 내용을 이어서 씁니다.";
            // 
            // txtContent
            // 
            this.txtContent.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(255)))), ((int)(((byte)(192)))));
            this.txtContent.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtContent.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.txtContent.Location = new System.Drawing.Point(12, 304);
            this.txtContent.MaxLength = 100;
            this.txtContent.Name = "txtContent";
            this.txtContent.Size = new System.Drawing.Size(946, 39);
            this.txtContent.TabIndex = 161;
            // 
            // lblLotNo
            // 
            this.lblLotNo.BackColor = System.Drawing.Color.WhiteSmoke;
            this.lblLotNo.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblLotNo.ColorContent = System.Drawing.Color.Transparent;
            this.lblLotNo.ColorLabel = System.Drawing.Color.WhiteSmoke;
            this.lblLotNo.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblLotNo.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblLotNo.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblLotNo.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblLotNo.Location = new System.Drawing.Point(519, 82);
            this.lblLotNo.Margin = new System.Windows.Forms.Padding(4, 5, 4, 5);
            this.lblLotNo.MoveControl = null;
            this.lblLotNo.Name = "lblLotNo";
            this.lblLotNo.Size = new System.Drawing.Size(175, 40);
            this.lblLotNo.TabIndex = 155;
            this.lblLotNo.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblLotNo.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblIndBarCode
            // 
            this.lblIndBarCode.BackColor = System.Drawing.Color.WhiteSmoke;
            this.lblIndBarCode.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblIndBarCode.ColorContent = System.Drawing.Color.Transparent;
            this.lblIndBarCode.ColorLabel = System.Drawing.Color.WhiteSmoke;
            this.lblIndBarCode.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblIndBarCode.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblIndBarCode.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblIndBarCode.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblIndBarCode.Location = new System.Drawing.Point(167, 82);
            this.lblIndBarCode.Margin = new System.Windows.Forms.Padding(4, 5, 4, 5);
            this.lblIndBarCode.MoveControl = null;
            this.lblIndBarCode.Name = "lblIndBarCode";
            this.lblIndBarCode.Size = new System.Drawing.Size(200, 40);
            this.lblIndBarCode.TabIndex = 153;
            this.lblIndBarCode.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblIndBarCode.TextVAlign = Infragistics.Win.VAlign.Middle;
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
            this.btnOK.Location = new System.Drawing.Point(8, 362);
            this.btnOK.Margin = new System.Windows.Forms.Padding(8, 9, 8, 9);
            this.btnOK.Name = "btnOK";
            this.btnOK.ParentBox = null;
            this.btnOK.Size = new System.Drawing.Size(230, 60);
            this.btnOK.TabIndex = 148;
            this.btnOK.Text = "비고수정 실행";
            this.btnOK.TextHAlign = Infragistics.Win.HAlign.Center;
            this.btnOK.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.btnOK.UpPic = null;
            this.btnOK.UseFlag = true;
            this.btnOK.Click += new System.EventHandler(this.btnOK_Click);
            // 
            // lblBeforeChange
            // 
            this.lblBeforeChange.BackColor = System.Drawing.Color.WhiteSmoke;
            this.lblBeforeChange.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblBeforeChange.ColorContent = System.Drawing.Color.Transparent;
            this.lblBeforeChange.ColorLabel = System.Drawing.Color.WhiteSmoke;
            this.lblBeforeChange.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblBeforeChange.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblBeforeChange.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblBeforeChange.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblBeforeChange.Location = new System.Drawing.Point(167, 144);
            this.lblBeforeChange.Margin = new System.Windows.Forms.Padding(4, 5, 4, 5);
            this.lblBeforeChange.MoveControl = null;
            this.lblBeforeChange.Name = "lblBeforeChange";
            this.lblBeforeChange.Size = new System.Drawing.Size(791, 70);
            this.lblBeforeChange.TabIndex = 146;
            this.lblBeforeChange.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblBeforeChange.TextVAlign = Infragistics.Win.VAlign.Top;
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
            this.btnCancel.Location = new System.Drawing.Point(728, 362);
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
            this.lblTitle.MoveControl = this;
            this.lblTitle.Name = "lblTitle";
            this.lblTitle.Size = new System.Drawing.Size(946, 60);
            this.lblTitle.TabIndex = 86;
            this.lblTitle.Text = "비고수정";
            this.lblTitle.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblTitle.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // POP_WRK85
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.WhiteSmoke;
            this.ClientSize = new System.Drawing.Size(969, 437);
            this.ControlBox = false;
            this.Controls.Add(this.txtContent);
            this.Controls.Add(this.lbInfo);
            this.Controls.Add(this.label5);
            this.Controls.Add(this.rbtnModify);
            this.Controls.Add(this.rbtnAppend);
            this.Controls.Add(this.panel1);
            this.Controls.Add(this.lblLotNo);
            this.Controls.Add(this.label4);
            this.Controls.Add(this.lblIndBarCode);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.btnOK);
            this.Controls.Add(this.lblBeforeChange);
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.lblTitle);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.Name = "POP_WRK85";
            this.ShowIcon = false;
            this.ShowInTaskbar = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Load += new System.EventHandler(this.POP_WRK85_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private Components.MESLabel lblTitle;
        private Components.MESButton btnCancel;
        private Components.MESLabel lblBeforeChange;
        private Components.MESButton btnOK;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label3;
        private Components.MESLabel lblIndBarCode;
        private System.Windows.Forms.Label label4;
        private Components.MESLabel lblLotNo;
        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.RadioButton rbtnAppend;
        private System.Windows.Forms.RadioButton rbtnModify;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.Label lbInfo;
        private System.Windows.Forms.TextBox txtContent;
    }
}