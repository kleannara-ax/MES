namespace SmartDas.POPUP
{
    partial class POP_Printer
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
            Infragistics.Win.Appearance appearance3 = new Infragistics.Win.Appearance();
            Infragistics.Win.Appearance appearance2 = new Infragistics.Win.Appearance();
            Infragistics.Win.ValueListItem valueListItem1 = new Infragistics.Win.ValueListItem();
            Infragistics.Win.ValueListItem valueListItem2 = new Infragistics.Win.ValueListItem();
            this.label1 = new System.Windows.Forms.Label();
            this.ucPrinter = new Infragistics.Win.UltraWinEditors.UltraComboEditor();
            this.ucPrtDPI = new Infragistics.Win.UltraWinEditors.UltraComboEditor();
            this.label2 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.upGapX = new System.Windows.Forms.NumericUpDown();
            this.upGapY = new System.Windows.Forms.NumericUpDown();
            this.label4 = new System.Windows.Forms.Label();
            this.btnTestPrint = new SmartDas.Components.MESButton();
            this.btnInput = new SmartDas.Components.MESButton();
            this.btnCancel = new SmartDas.Components.MESButton();
            this.labTitle = new SmartDas.Components.MESLabel();
            ((System.ComponentModel.ISupportInitialize)(this.ucPrinter)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.ucPrtDPI)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.upGapX)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.upGapY)).BeginInit();
            this.SuspendLayout();
            // 
            // label1
            // 
            this.label1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(76)))), ((int)(((byte)(121)))), ((int)(((byte)(211)))));
            this.label1.Font = new System.Drawing.Font("맑은 고딕", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label1.ForeColor = System.Drawing.Color.White;
            this.label1.Location = new System.Drawing.Point(5, 144);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(144, 50);
            this.label1.TabIndex = 140;
            this.label1.Text = "라벨 프린터";
            this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // ucPrinter
            // 
            appearance3.BackColor = System.Drawing.Color.LightGoldenrodYellow;
            this.ucPrinter.Appearance = appearance3;
            this.ucPrinter.AutoSize = false;
            this.ucPrinter.BackColor = System.Drawing.Color.LightGoldenrodYellow;
            this.ucPrinter.DropDownStyle = Infragistics.Win.DropDownStyle.DropDownList;
            this.ucPrinter.Font = new System.Drawing.Font("맑은 고딕", 14.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.ucPrinter.Location = new System.Drawing.Point(155, 144);
            this.ucPrinter.MinimumSize = new System.Drawing.Size(0, 50);
            this.ucPrinter.Name = "ucPrinter";
            this.ucPrinter.Size = new System.Drawing.Size(444, 50);
            this.ucPrinter.TabIndex = 270;
            // 
            // ucPrtDPI
            // 
            appearance2.BackColor = System.Drawing.Color.LightGoldenrodYellow;
            this.ucPrtDPI.Appearance = appearance2;
            this.ucPrtDPI.AutoSize = false;
            this.ucPrtDPI.BackColor = System.Drawing.Color.LightGoldenrodYellow;
            this.ucPrtDPI.DropDownStyle = Infragistics.Win.DropDownStyle.DropDownList;
            this.ucPrtDPI.Font = new System.Drawing.Font("맑은 고딕", 14.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            valueListItem1.DataValue = "200";
            valueListItem1.DisplayText = "200 (203)";
            valueListItem2.DataValue = "300";
            valueListItem2.DisplayText = "300";
            this.ucPrtDPI.Items.AddRange(new Infragistics.Win.ValueListItem[] {
            valueListItem1,
            valueListItem2});
            this.ucPrtDPI.Location = new System.Drawing.Point(154, 206);
            this.ucPrtDPI.MinimumSize = new System.Drawing.Size(0, 50);
            this.ucPrtDPI.Name = "ucPrtDPI";
            this.ucPrtDPI.Size = new System.Drawing.Size(444, 50);
            this.ucPrtDPI.TabIndex = 272;
            // 
            // label2
            // 
            this.label2.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(76)))), ((int)(((byte)(121)))), ((int)(((byte)(211)))));
            this.label2.Font = new System.Drawing.Font("맑은 고딕", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label2.ForeColor = System.Drawing.Color.White;
            this.label2.Location = new System.Drawing.Point(4, 206);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(144, 50);
            this.label2.TabIndex = 271;
            this.label2.Text = "프린터 DPI";
            this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Font = new System.Drawing.Font("맑은 고딕", 14.25F, System.Drawing.FontStyle.Bold);
            this.label3.Location = new System.Drawing.Point(376, 91);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(95, 25);
            this.label3.TabIndex = 275;
            this.label3.Text = "왼쪽 여백";
            this.label3.Visible = false;
            // 
            // upGapX
            // 
            this.upGapX.BackColor = System.Drawing.Color.LightGoldenrodYellow;
            this.upGapX.Font = new System.Drawing.Font("맑은 고딕", 14.25F, System.Drawing.FontStyle.Bold);
            this.upGapX.Location = new System.Drawing.Point(479, 89);
            this.upGapX.Maximum = new decimal(new int[] {
            500,
            0,
            0,
            0});
            this.upGapX.Minimum = new decimal(new int[] {
            300,
            0,
            0,
            -2147483648});
            this.upGapX.Name = "upGapX";
            this.upGapX.Size = new System.Drawing.Size(120, 33);
            this.upGapX.TabIndex = 277;
            this.upGapX.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
            this.upGapX.Visible = false;
            // 
            // upGapY
            // 
            this.upGapY.BackColor = System.Drawing.Color.LightGoldenrodYellow;
            this.upGapY.Font = new System.Drawing.Font("맑은 고딕", 14.25F, System.Drawing.FontStyle.Bold);
            this.upGapY.Location = new System.Drawing.Point(114, 89);
            this.upGapY.Maximum = new decimal(new int[] {
            500,
            0,
            0,
            0});
            this.upGapY.Minimum = new decimal(new int[] {
            300,
            0,
            0,
            -2147483648});
            this.upGapY.Name = "upGapY";
            this.upGapY.Size = new System.Drawing.Size(120, 33);
            this.upGapY.TabIndex = 279;
            this.upGapY.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Font = new System.Drawing.Font("맑은 고딕", 14.25F, System.Drawing.FontStyle.Bold);
            this.label4.Location = new System.Drawing.Point(11, 91);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(95, 25);
            this.label4.TabIndex = 278;
            this.label4.Text = "위쪽 여백";
            // 
            // btnTestPrint
            // 
            this.btnTestPrint.AlarmColor = System.Drawing.Color.IndianRed;
            this.btnTestPrint.BackColor = System.Drawing.Color.Transparent;
            this.btnTestPrint.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.btnTestPrint.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnTestPrint.ButtonClickType = SmartDas.Components.MESButton.ButtonClickTypeEnum.Click;
            this.btnTestPrint.ButtonPressed = false;
            this.btnTestPrint.ClickBackColor = System.Drawing.Color.Transparent;
            this.btnTestPrint.DownPic = null;
            this.btnTestPrint.ExTag = null;
            this.btnTestPrint.Font = new System.Drawing.Font("맑은 고딕", 20.25F, System.Drawing.FontStyle.Bold);
            this.btnTestPrint.FontSize = 20.25F;
            this.btnTestPrint.LinkButtonBox = null;
            this.btnTestPrint.LinkDatePicker = null;
            this.btnTestPrint.LinkGrid = null;
            this.btnTestPrint.LinkMoveSize = 0;
            this.btnTestPrint.LinkType = SmartDas.Components.MESButton.LinkGridButtonType.Up;
            this.btnTestPrint.Location = new System.Drawing.Point(225, 269);
            this.btnTestPrint.Margin = new System.Windows.Forms.Padding(8, 9, 8, 9);
            this.btnTestPrint.Name = "btnTestPrint";
            this.btnTestPrint.ParentBox = null;
            this.btnTestPrint.Size = new System.Drawing.Size(160, 57);
            this.btnTestPrint.TabIndex = 280;
            this.btnTestPrint.Text = "시험인쇄";
            this.btnTestPrint.TextHAlign = Infragistics.Win.HAlign.Center;
            this.btnTestPrint.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.btnTestPrint.UpPic = null;
            this.btnTestPrint.UseFlag = true;
            this.btnTestPrint.Visible = false;
            this.btnTestPrint.Click += new System.EventHandler(this.btnTestPrint_Click);
            // 
            // btnInput
            // 
            this.btnInput.AlarmColor = System.Drawing.Color.IndianRed;
            this.btnInput.BackColor = System.Drawing.Color.Transparent;
            this.btnInput.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.btnInput.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnInput.ButtonClickType = SmartDas.Components.MESButton.ButtonClickTypeEnum.Click;
            this.btnInput.ButtonPressed = false;
            this.btnInput.ClickBackColor = System.Drawing.Color.Transparent;
            this.btnInput.DownPic = null;
            this.btnInput.ExTag = null;
            this.btnInput.Font = new System.Drawing.Font("맑은 고딕", 20.25F, System.Drawing.FontStyle.Bold);
            this.btnInput.FontSize = 20.25F;
            this.btnInput.LinkButtonBox = null;
            this.btnInput.LinkDatePicker = null;
            this.btnInput.LinkGrid = null;
            this.btnInput.LinkMoveSize = 0;
            this.btnInput.LinkType = SmartDas.Components.MESButton.LinkGridButtonType.Up;
            this.btnInput.Location = new System.Drawing.Point(6, 271);
            this.btnInput.Margin = new System.Windows.Forms.Padding(8, 9, 8, 9);
            this.btnInput.Name = "btnInput";
            this.btnInput.ParentBox = null;
            this.btnInput.Size = new System.Drawing.Size(160, 57);
            this.btnInput.TabIndex = 139;
            this.btnInput.Text = "등록";
            this.btnInput.TextHAlign = Infragistics.Win.HAlign.Center;
            this.btnInput.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.btnInput.UpPic = null;
            this.btnInput.UseFlag = true;
            this.btnInput.Click += new System.EventHandler(this.btnInput_Click);
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
            this.btnCancel.Font = new System.Drawing.Font("맑은 고딕", 20.25F, System.Drawing.FontStyle.Bold);
            this.btnCancel.FontSize = 20.25F;
            this.btnCancel.LinkButtonBox = null;
            this.btnCancel.LinkDatePicker = null;
            this.btnCancel.LinkGrid = null;
            this.btnCancel.LinkMoveSize = 0;
            this.btnCancel.LinkType = SmartDas.Components.MESButton.LinkGridButtonType.Up;
            this.btnCancel.Location = new System.Drawing.Point(440, 269);
            this.btnCancel.Margin = new System.Windows.Forms.Padding(8, 9, 8, 9);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.ParentBox = null;
            this.btnCancel.Size = new System.Drawing.Size(160, 57);
            this.btnCancel.TabIndex = 86;
            this.btnCancel.Text = "닫기";
            this.btnCancel.TextHAlign = Infragistics.Win.HAlign.Center;
            this.btnCancel.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.btnCancel.UpPic = null;
            this.btnCancel.UseFlag = true;
            this.btnCancel.Click += new System.EventHandler(this.btnCancel_Click);
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
            this.labTitle.Location = new System.Drawing.Point(6, 6);
            this.labTitle.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.labTitle.MoveControl = this;
            this.labTitle.Name = "labTitle";
            this.labTitle.Size = new System.Drawing.Size(597, 59);
            this.labTitle.TabIndex = 4;
            this.labTitle.Text = "프린터 설 정";
            this.labTitle.TextHAlign = Infragistics.Win.HAlign.Center;
            this.labTitle.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // POP_Printer
            // 
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
            this.BackColor = System.Drawing.Color.WhiteSmoke;
            this.ClientSize = new System.Drawing.Size(611, 346);
            this.ControlBox = false;
            this.Controls.Add(this.btnTestPrint);
            this.Controls.Add(this.upGapY);
            this.Controls.Add(this.label4);
            this.Controls.Add(this.upGapX);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.ucPrtDPI);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.ucPrinter);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.btnInput);
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.labTitle);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.Name = "POP_Printer";
            this.ShowIcon = false;
            this.ShowInTaskbar = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Load += new System.EventHandler(this.POP_Printer_Load);
            ((System.ComponentModel.ISupportInitialize)(this.ucPrinter)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.ucPrtDPI)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.upGapX)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.upGapY)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private Components.MESLabel labTitle;
        private Components.MESButton btnCancel;
        private Components.MESButton btnInput;
        private System.Windows.Forms.Label label1;
        private Infragistics.Win.UltraWinEditors.UltraComboEditor ucPrinter;
        private Infragistics.Win.UltraWinEditors.UltraComboEditor ucPrtDPI;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.NumericUpDown upGapX;
        private System.Windows.Forms.NumericUpDown upGapY;
        private System.Windows.Forms.Label label4;
        private Components.MESButton btnTestPrint;
    }
}