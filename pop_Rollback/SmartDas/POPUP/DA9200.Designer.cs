namespace SmartDas.POPUP
{
    partial class DA9200
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
            this.txtContent = new Infragistics.Win.UltraWinEditors.UltraTextEditor();
            this.btnCancel = new SmartDas.Components.MESButton();
            this.btnOK = new SmartDas.Components.MESButton();
            this.btnClear = new SmartDas.Components.MESButton();
            this.btnBack = new SmartDas.Components.MESButton();
            this.btnSpace = new SmartDas.Components.MESButton();
            this.btnChnage = new SmartDas.Components.MESButton();
            this.labTitle = new SmartDas.Components.MESLabel();
            this.labHeader = new SmartDas.Components.MESLabel();
            this.pnlButtons = new System.Windows.Forms.Panel();
            ((System.ComponentModel.ISupportInitialize)(this.txtContent)).BeginInit();
            this.SuspendLayout();
            // 
            // txtContent
            // 
            this.txtContent.Font = new System.Drawing.Font("맑은 고딕", 21.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtContent.ImeMode = System.Windows.Forms.ImeMode.Disable;
            this.txtContent.Location = new System.Drawing.Point(196, 63);
            this.txtContent.MinimumSize = new System.Drawing.Size(0, 54);
            this.txtContent.Name = "txtContent";
            this.txtContent.Size = new System.Drawing.Size(784, 54);
            this.txtContent.TabIndex = 11;
            this.txtContent.KeyDown += new System.Windows.Forms.KeyEventHandler(this.txtContent_KeyDown);
            this.txtContent.Leave += new System.EventHandler(this.txtContent_Leave);
            // 
            // btnCancel
            // 
            this.btnCancel.AlarmColor = System.Drawing.Color.IndianRed;
            this.btnCancel.BackColor = System.Drawing.Color.Transparent;
            this.btnCancel.BackGradientStyle = Infragistics.Win.GradientStyle.None;
            this.btnCancel.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnCancel.ButtonClickType = SmartDas.Components.MESButton.ButtonClickTypeEnum.Click;
            this.btnCancel.ButtonPressed = false;
            this.btnCancel.ClickBackColor = System.Drawing.Color.Yellow;
            this.btnCancel.DownPic = null;
            this.btnCancel.ExTag = null;
            this.btnCancel.Font = new System.Drawing.Font("맑은 고딕", 21.75F, System.Drawing.FontStyle.Bold);
            this.btnCancel.FontSize = 21.75F;
            this.btnCancel.LinkButtonBox = null;
            this.btnCancel.LinkDatePicker = null;
            this.btnCancel.LinkGrid = null;
            this.btnCancel.LinkMoveSize = 0;
            this.btnCancel.LinkType = SmartDas.Components.MESButton.LinkGridButtonType.Up;
            this.btnCancel.Location = new System.Drawing.Point(811, 577);
            this.btnCancel.Margin = new System.Windows.Forms.Padding(8, 9, 8, 9);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.ParentBox = null;
            this.btnCancel.Size = new System.Drawing.Size(169, 72);
            this.btnCancel.TabIndex = 10;
            this.btnCancel.Text = "취소";
            this.btnCancel.TextHAlign = Infragistics.Win.HAlign.Center;
            this.btnCancel.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.btnCancel.UpPic = null;
            this.btnCancel.UseFlag = true;
            this.btnCancel.Click += new System.EventHandler(this.btn_Click);
            // 
            // btnOK
            // 
            this.btnOK.AlarmColor = System.Drawing.Color.IndianRed;
            this.btnOK.BackColor = System.Drawing.Color.Transparent;
            this.btnOK.BackGradientStyle = Infragistics.Win.GradientStyle.None;
            this.btnOK.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnOK.ButtonClickType = SmartDas.Components.MESButton.ButtonClickTypeEnum.Click;
            this.btnOK.ButtonPressed = false;
            this.btnOK.ClickBackColor = System.Drawing.Color.Yellow;
            this.btnOK.DownPic = null;
            this.btnOK.ExTag = null;
            this.btnOK.Font = new System.Drawing.Font("맑은 고딕", 21.75F, System.Drawing.FontStyle.Bold);
            this.btnOK.FontSize = 21.75F;
            this.btnOK.LinkButtonBox = null;
            this.btnOK.LinkDatePicker = null;
            this.btnOK.LinkGrid = null;
            this.btnOK.LinkMoveSize = 0;
            this.btnOK.LinkType = SmartDas.Components.MESButton.LinkGridButtonType.Up;
            this.btnOK.Location = new System.Drawing.Point(627, 577);
            this.btnOK.Margin = new System.Windows.Forms.Padding(8, 9, 8, 9);
            this.btnOK.Name = "btnOK";
            this.btnOK.ParentBox = null;
            this.btnOK.Size = new System.Drawing.Size(169, 72);
            this.btnOK.TabIndex = 9;
            this.btnOK.Text = "확인";
            this.btnOK.TextHAlign = Infragistics.Win.HAlign.Center;
            this.btnOK.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.btnOK.UpPic = null;
            this.btnOK.UseFlag = true;
            this.btnOK.Click += new System.EventHandler(this.btn_Click);
            // 
            // btnClear
            // 
            this.btnClear.AlarmColor = System.Drawing.Color.IndianRed;
            this.btnClear.BackColor = System.Drawing.Color.Transparent;
            this.btnClear.BackGradientStyle = Infragistics.Win.GradientStyle.None;
            this.btnClear.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnClear.ButtonClickType = SmartDas.Components.MESButton.ButtonClickTypeEnum.Click;
            this.btnClear.ButtonPressed = false;
            this.btnClear.ClickBackColor = System.Drawing.Color.Yellow;
            this.btnClear.DownPic = null;
            this.btnClear.ExTag = null;
            this.btnClear.Font = new System.Drawing.Font("맑은 고딕", 21.75F, System.Drawing.FontStyle.Bold);
            this.btnClear.FontSize = 21.75F;
            this.btnClear.LinkButtonBox = null;
            this.btnClear.LinkDatePicker = null;
            this.btnClear.LinkGrid = null;
            this.btnClear.LinkMoveSize = 0;
            this.btnClear.LinkType = SmartDas.Components.MESButton.LinkGridButtonType.Up;
            this.btnClear.Location = new System.Drawing.Point(442, 577);
            this.btnClear.Margin = new System.Windows.Forms.Padding(8, 9, 8, 9);
            this.btnClear.Name = "btnClear";
            this.btnClear.ParentBox = null;
            this.btnClear.Size = new System.Drawing.Size(169, 72);
            this.btnClear.TabIndex = 8;
            this.btnClear.Text = "모두지움";
            this.btnClear.TextHAlign = Infragistics.Win.HAlign.Center;
            this.btnClear.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.btnClear.UpPic = null;
            this.btnClear.UseFlag = true;
            this.btnClear.Click += new System.EventHandler(this.btn_Click);
            // 
            // btnBack
            // 
            this.btnBack.AlarmColor = System.Drawing.Color.IndianRed;
            this.btnBack.BackColor = System.Drawing.Color.Transparent;
            this.btnBack.BackGradientStyle = Infragistics.Win.GradientStyle.None;
            this.btnBack.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnBack.ButtonClickType = SmartDas.Components.MESButton.ButtonClickTypeEnum.Click;
            this.btnBack.ButtonPressed = false;
            this.btnBack.ClickBackColor = System.Drawing.Color.Yellow;
            this.btnBack.DownPic = null;
            this.btnBack.ExTag = null;
            this.btnBack.Font = new System.Drawing.Font("맑은 고딕", 21.75F, System.Drawing.FontStyle.Bold);
            this.btnBack.FontSize = 21.75F;
            this.btnBack.LinkButtonBox = null;
            this.btnBack.LinkDatePicker = null;
            this.btnBack.LinkGrid = null;
            this.btnBack.LinkMoveSize = 0;
            this.btnBack.LinkType = SmartDas.Components.MESButton.LinkGridButtonType.Up;
            this.btnBack.Location = new System.Drawing.Point(340, 577);
            this.btnBack.Margin = new System.Windows.Forms.Padding(8, 9, 8, 9);
            this.btnBack.Name = "btnBack";
            this.btnBack.ParentBox = null;
            this.btnBack.Size = new System.Drawing.Size(88, 72);
            this.btnBack.TabIndex = 7;
            this.btnBack.Text = "◀";
            this.btnBack.TextHAlign = Infragistics.Win.HAlign.Center;
            this.btnBack.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.btnBack.UpPic = null;
            this.btnBack.UseFlag = true;
            this.btnBack.Click += new System.EventHandler(this.btn_Click);
            // 
            // btnSpace
            // 
            this.btnSpace.AlarmColor = System.Drawing.Color.IndianRed;
            this.btnSpace.BackColor = System.Drawing.Color.Transparent;
            this.btnSpace.BackGradientStyle = Infragistics.Win.GradientStyle.None;
            this.btnSpace.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnSpace.ButtonClickType = SmartDas.Components.MESButton.ButtonClickTypeEnum.Click;
            this.btnSpace.ButtonPressed = false;
            this.btnSpace.ClickBackColor = System.Drawing.Color.Yellow;
            this.btnSpace.DownPic = null;
            this.btnSpace.ExTag = null;
            this.btnSpace.Font = new System.Drawing.Font("맑은 고딕", 21.75F, System.Drawing.FontStyle.Bold);
            this.btnSpace.FontSize = 21.75F;
            this.btnSpace.LinkButtonBox = null;
            this.btnSpace.LinkDatePicker = null;
            this.btnSpace.LinkGrid = null;
            this.btnSpace.LinkMoveSize = 0;
            this.btnSpace.LinkType = SmartDas.Components.MESButton.LinkGridButtonType.Up;
            this.btnSpace.Location = new System.Drawing.Point(157, 577);
            this.btnSpace.Margin = new System.Windows.Forms.Padding(8, 9, 8, 9);
            this.btnSpace.Name = "btnSpace";
            this.btnSpace.ParentBox = null;
            this.btnSpace.Size = new System.Drawing.Size(169, 72);
            this.btnSpace.TabIndex = 6;
            this.btnSpace.Text = " SPACE";
            this.btnSpace.TextHAlign = Infragistics.Win.HAlign.Center;
            this.btnSpace.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.btnSpace.UpPic = null;
            this.btnSpace.UseFlag = true;
            this.btnSpace.Click += new System.EventHandler(this.btn_Click);
            // 
            // btnChnage
            // 
            this.btnChnage.AlarmColor = System.Drawing.Color.IndianRed;
            this.btnChnage.BackColor = System.Drawing.Color.Transparent;
            this.btnChnage.BackGradientStyle = Infragistics.Win.GradientStyle.None;
            this.btnChnage.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnChnage.ButtonClickType = SmartDas.Components.MESButton.ButtonClickTypeEnum.Click;
            this.btnChnage.ButtonPressed = false;
            this.btnChnage.ClickBackColor = System.Drawing.Color.Yellow;
            this.btnChnage.DownPic = null;
            this.btnChnage.ExTag = null;
            this.btnChnage.Font = new System.Drawing.Font("맑은 고딕", 21.75F, System.Drawing.FontStyle.Bold);
            this.btnChnage.FontSize = 21.75F;
            this.btnChnage.LinkButtonBox = null;
            this.btnChnage.LinkDatePicker = null;
            this.btnChnage.LinkGrid = null;
            this.btnChnage.LinkMoveSize = 0;
            this.btnChnage.LinkType = SmartDas.Components.MESButton.LinkGridButtonType.Up;
            this.btnChnage.Location = new System.Drawing.Point(12, 577);
            this.btnChnage.Margin = new System.Windows.Forms.Padding(8, 9, 8, 9);
            this.btnChnage.Name = "btnChnage";
            this.btnChnage.ParentBox = null;
            this.btnChnage.Size = new System.Drawing.Size(131, 72);
            this.btnChnage.TabIndex = 5;
            this.btnChnage.Text = "대문자";
            this.btnChnage.TextHAlign = Infragistics.Win.HAlign.Center;
            this.btnChnage.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.btnChnage.UpPic = null;
            this.btnChnage.UseFlag = true;
            this.btnChnage.Click += new System.EventHandler(this.btn_Click);
            // 
            // labTitle
            // 
            this.labTitle.BackColor = System.Drawing.Color.RoyalBlue;
            this.labTitle.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.labTitle.ColorContent = System.Drawing.Color.Transparent;
            this.labTitle.ColorLabel = System.Drawing.Color.RoyalBlue;
            this.labTitle.ColorReadOnly = System.Drawing.Color.Transparent;
            this.labTitle.Font = new System.Drawing.Font("맑은 고딕", 24F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.labTitle.ForeColor = System.Drawing.Color.White;
            this.labTitle.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.labTitle.Location = new System.Drawing.Point(12, 5);
            this.labTitle.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.labTitle.MoveControl = this;
            this.labTitle.Name = "labTitle";
            this.labTitle.Size = new System.Drawing.Size(968, 53);
            this.labTitle.TabIndex = 4;
            this.labTitle.Text = "입력 키보드";
            this.labTitle.TextHAlign = Infragistics.Win.HAlign.Center;
            this.labTitle.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // labHeader
            // 
            this.labHeader.BackColor = System.Drawing.Color.RoyalBlue;
            this.labHeader.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.labHeader.ColorContent = System.Drawing.Color.Transparent;
            this.labHeader.ColorLabel = System.Drawing.Color.RoyalBlue;
            this.labHeader.ColorReadOnly = System.Drawing.Color.Transparent;
            this.labHeader.Font = new System.Drawing.Font("맑은 고딕", 22F, System.Drawing.FontStyle.Bold);
            this.labHeader.ForeColor = System.Drawing.Color.White;
            this.labHeader.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.labHeader.Location = new System.Drawing.Point(12, 63);
            this.labHeader.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.labHeader.MoveControl = null;
            this.labHeader.Name = "labHeader";
            this.labHeader.Size = new System.Drawing.Size(176, 53);
            this.labHeader.TabIndex = 2;
            this.labHeader.Text = "문장";
            this.labHeader.TextHAlign = Infragistics.Win.HAlign.Center;
            this.labHeader.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // pnlButtons
            // 
            this.pnlButtons.Location = new System.Drawing.Point(14, 126);
            this.pnlButtons.Name = "pnlButtons";
            this.pnlButtons.Size = new System.Drawing.Size(968, 439);
            this.pnlButtons.TabIndex = 12;
            // 
            // DA9200
            // 
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
            this.BackColor = System.Drawing.Color.WhiteSmoke;
            this.ClientSize = new System.Drawing.Size(994, 659);
            this.ControlBox = false;
            this.Controls.Add(this.pnlButtons);
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.txtContent);
            this.Controls.Add(this.btnOK);
            this.Controls.Add(this.btnClear);
            this.Controls.Add(this.btnBack);
            this.Controls.Add(this.btnSpace);
            this.Controls.Add(this.btnChnage);
            this.Controls.Add(this.labTitle);
            this.Controls.Add(this.labHeader);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.Name = "DA9200";
            this.ShowIcon = false;
            this.ShowInTaskbar = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Activated += new System.EventHandler(this.DA9200_Activated);
            this.Load += new System.EventHandler(this.DA9200_Load);
            ((System.ComponentModel.ISupportInitialize)(this.txtContent)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private Components.MESLabel labHeader;
        private Components.MESLabel labTitle;
        private Components.MESButton btnChnage;
        private Components.MESButton btnSpace;
        private Components.MESButton btnBack;
        private Components.MESButton btnClear;
        private Components.MESButton btnOK;
        private Components.MESButton btnCancel;
        private Infragistics.Win.UltraWinEditors.UltraTextEditor txtContent;
        private System.Windows.Forms.Panel pnlButtons;
    }
}