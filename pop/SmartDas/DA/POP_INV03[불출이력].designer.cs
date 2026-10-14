using SmartDas.Components;

namespace SmartDas
{
    partial class POP_INV03
    {
        /// <summary>
        /// 필수 디자이너 변수입니다.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// 사용 중인 모든 리소스를 정리합니다.
        /// </summary>
        /// <param name="disposing">관리되는 리소스를 삭제해야 하면 true이고, 그렇지 않으면 false입니다.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form 디자이너에서 생성한 코드

        /// <summary>
        /// 디자이너 지원에 필요한 메서드입니다.
        /// 이 메서드의 내용을 코드 편집기로 수정하지 마십시오.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(POP_INV03));
            this.label2 = new System.Windows.Forms.Label();
            this.label1 = new System.Windows.Forms.Label();
            this.bBox1 = new SmartDas.Components.ButtonBox();
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.txtMATNR_NM = new System.Windows.Forms.TextBox();
            this.txtWRK_ORDR = new System.Windows.Forms.TextBox();
            this.txtMATNR = new System.Windows.Forms.TextBox();
            this.butWorkDate = new System.Windows.Forms.Button();
            this.label4 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.dtpWorkDate = new System.Windows.Forms.DateTimePicker();
            this.btnFind = new SmartDas.Components.MESButton();
            this.Grid1 = new SmartDas.Components.MESGrid();
            ((System.ComponentModel.ISupportInitialize)(this.GroupBody)).BeginInit();
            this.GroupBody.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).BeginInit();
            this.splitContainer1.Panel1.SuspendLayout();
            this.splitContainer1.Panel2.SuspendLayout();
            this.splitContainer1.SuspendLayout();
            this.SuspendLayout();
            // 
            // lblTitle
            // 
            this.lblTitle.Font = new System.Drawing.Font("맑은 고딕", 30F, System.Drawing.FontStyle.Bold);
            this.lblTitle.Text = "타이틀";
            // 
            // GroupBody
            // 
            this.GroupBody.Controls.Add(this.splitContainer1);
            // 
            // btnRightPage
            // 
            this.btnRightPage.LinkGrid = this.Grid1;
            // 
            // btnLeftPage
            // 
            this.btnLeftPage.LinkGrid = this.Grid1;
            // 
            // label2
            // 
            this.label2.BackColor = System.Drawing.Color.Gray;
            this.label2.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label2.ForeColor = System.Drawing.Color.White;
            this.label2.Location = new System.Drawing.Point(9, 11);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(120, 50);
            this.label2.TabIndex = 49;
            this.label2.Text = "작업일";
            this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label1
            // 
            this.label1.BackColor = System.Drawing.Color.Gray;
            this.label1.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label1.ForeColor = System.Drawing.Color.White;
            this.label1.Location = new System.Drawing.Point(9, 70);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(120, 50);
            this.label1.TabIndex = 51;
            this.label1.Text = "자재";
            this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // bBox1
            // 
            this.bBox1.BackColor = System.Drawing.Color.MidnightBlue;
            this.bBox1.BackgroundImageLayout = System.Windows.Forms.ImageLayout.None;
            this.bBox1.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.bBox1.ButtonBoxType = SmartDas.Components.ButtonBox.ButtonBoxTypeEnum.Selection;
            this.bBox1.CountX = 1;
            this.bBox1.CountY = 1;
            this.bBox1.CurrentPage = 0;
            this.bBox1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.bBox1.ExTag = "";
            this.bBox1.Font = new System.Drawing.Font("맑은 고딕", 24F, System.Drawing.FontStyle.Bold);
            this.bBox1.FontSize = 24F;
            this.bBox1.Location = new System.Drawing.Point(0, 0);
            this.bBox1.MarginIn = new System.Windows.Forms.Padding(3);
            this.bBox1.MarginOut = new System.Windows.Forms.Padding(3);
            this.bBox1.Name = "bBox1";
            this.bBox1.SelectCommand = null;
            this.bBox1.SelectionMode = SmartDas.Components.ButtonBox.SelectionModeEnum.Single;
            this.bBox1.SelectProcedureName = null;
            this.bBox1.Size = new System.Drawing.Size(1274, 81);
            this.bBox1.TabIndex = 64;
            this.bBox1.buttonClickEvent += new SmartDas.Components.ButtonBox.ButtonClick(this.bBox1_buttonClickEvent);
            // 
            // splitContainer1
            // 
            this.splitContainer1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer1.IsSplitterFixed = true;
            this.splitContainer1.Location = new System.Drawing.Point(1, 0);
            this.splitContainer1.Name = "splitContainer1";
            this.splitContainer1.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // splitContainer1.Panel1
            // 
            this.splitContainer1.Panel1.Controls.Add(this.txtMATNR_NM);
            this.splitContainer1.Panel1.Controls.Add(this.txtWRK_ORDR);
            this.splitContainer1.Panel1.Controls.Add(this.txtMATNR);
            this.splitContainer1.Panel1.Controls.Add(this.butWorkDate);
            this.splitContainer1.Panel1.Controls.Add(this.label4);
            this.splitContainer1.Panel1.Controls.Add(this.label3);
            this.splitContainer1.Panel1.Controls.Add(this.dtpWorkDate);
            this.splitContainer1.Panel1.Controls.Add(this.btnFind);
            this.splitContainer1.Panel1.Controls.Add(this.Grid1);
            this.splitContainer1.Panel1.Controls.Add(this.label2);
            this.splitContainer1.Panel1.Controls.Add(this.label1);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.bBox1);
            this.splitContainer1.Size = new System.Drawing.Size(1274, 874);
            this.splitContainer1.SplitterDistance = 789;
            this.splitContainer1.TabIndex = 65;
            // 
            // txtMATNR_NM
            // 
            this.txtMATNR_NM.Font = new System.Drawing.Font("맑은 고딕", 20.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtMATNR_NM.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.txtMATNR_NM.Location = new System.Drawing.Point(555, 70);
            this.txtMATNR_NM.MinimumSize = new System.Drawing.Size(280, 50);
            this.txtMATNR_NM.Name = "txtMATNR_NM";
            this.txtMATNR_NM.Size = new System.Drawing.Size(400, 50);
            this.txtMATNR_NM.TabIndex = 182;
            // 
            // txtWRK_ORDR
            // 
            this.txtWRK_ORDR.Font = new System.Drawing.Font("맑은 고딕", 20.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtWRK_ORDR.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.txtWRK_ORDR.Location = new System.Drawing.Point(555, 10);
            this.txtWRK_ORDR.MinimumSize = new System.Drawing.Size(280, 50);
            this.txtWRK_ORDR.Name = "txtWRK_ORDR";
            this.txtWRK_ORDR.Size = new System.Drawing.Size(400, 50);
            this.txtWRK_ORDR.TabIndex = 181;
            this.txtWRK_ORDR.Visible = false;
            // 
            // txtMATNR
            // 
            this.txtMATNR.Font = new System.Drawing.Font("맑은 고딕", 20.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtMATNR.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.txtMATNR.Location = new System.Drawing.Point(135, 70);
            this.txtMATNR.MinimumSize = new System.Drawing.Size(280, 50);
            this.txtMATNR.Name = "txtMATNR";
            this.txtMATNR.Size = new System.Drawing.Size(280, 50);
            this.txtMATNR.TabIndex = 180;
            // 
            // butWorkDate
            // 
            this.butWorkDate.BackgroundImage = global::SmartDas.Properties.Resources.Calendar;
            this.butWorkDate.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center;
            this.butWorkDate.CausesValidation = false;
            this.butWorkDate.FlatAppearance.BorderSize = 0;
            this.butWorkDate.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(192)))), ((int)(((byte)(192)))));
            this.butWorkDate.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.butWorkDate.Font = new System.Drawing.Font("굴림", 11.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.butWorkDate.Location = new System.Drawing.Point(367, 13);
            this.butWorkDate.Name = "butWorkDate";
            this.butWorkDate.Size = new System.Drawing.Size(46, 46);
            this.butWorkDate.TabIndex = 130;
            this.butWorkDate.UseVisualStyleBackColor = false;
            this.butWorkDate.Click += new System.EventHandler(this.butWorkDate_Click);
            // 
            // label4
            // 
            this.label4.BackColor = System.Drawing.Color.Gray;
            this.label4.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label4.ForeColor = System.Drawing.Color.White;
            this.label4.Location = new System.Drawing.Point(429, 70);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(120, 50);
            this.label4.TabIndex = 127;
            this.label4.Text = "자재명";
            this.label4.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label3
            // 
            this.label3.BackColor = System.Drawing.Color.Gray;
            this.label3.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label3.ForeColor = System.Drawing.Color.White;
            this.label3.Location = new System.Drawing.Point(429, 11);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(120, 50);
            this.label3.TabIndex = 125;
            this.label3.Text = "지시번호";
            this.label3.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.label3.Visible = false;
            // 
            // dtpWorkDate
            // 
            this.dtpWorkDate.CalendarFont = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.dtpWorkDate.CustomFormat = "yyyy-MM-dd";
            this.dtpWorkDate.Font = new System.Drawing.Font("맑은 고딕", 20.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.dtpWorkDate.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtpWorkDate.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.dtpWorkDate.Location = new System.Drawing.Point(135, 11);
            this.dtpWorkDate.MinimumSize = new System.Drawing.Size(0, 50);
            this.dtpWorkDate.Name = "dtpWorkDate";
            this.dtpWorkDate.ShowUpDown = true;
            this.dtpWorkDate.Size = new System.Drawing.Size(280, 50);
            this.dtpWorkDate.TabIndex = 124;
            this.dtpWorkDate.DropDown += new System.EventHandler(this.dtpDate_DropDown);
            // 
            // btnFind
            // 
            this.btnFind.AlarmColor = System.Drawing.Color.IndianRed;
            this.btnFind.BackColor = System.Drawing.Color.Transparent;
            this.btnFind.BackGradientStyle = Infragistics.Win.GradientStyle.None;
            this.btnFind.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnFind.ButtonClickType = SmartDas.Components.MESButton.ButtonClickTypeEnum.Click;
            this.btnFind.ButtonPressed = false;
            this.btnFind.ClickBackColor = System.Drawing.Color.Yellow;
            this.btnFind.DownPic = null;
            this.btnFind.ExTag = null;
            this.btnFind.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold);
            this.btnFind.FontSize = 14F;
            this.btnFind.LinkButtonBox = null;
            this.btnFind.LinkDatePicker = null;
            this.btnFind.LinkGrid = null;
            this.btnFind.LinkMoveSize = 0;
            this.btnFind.LinkType = SmartDas.Components.MESButton.LinkGridButtonType.Up;
            this.btnFind.Location = new System.Drawing.Point(1106, 11);
            this.btnFind.Margin = new System.Windows.Forms.Padding(0);
            this.btnFind.MaximumSize = new System.Drawing.Size(300, 300);
            this.btnFind.Name = "btnFind";
            this.btnFind.ParentBox = null;
            this.btnFind.Size = new System.Drawing.Size(154, 110);
            this.btnFind.TabIndex = 73;
            this.btnFind.Text = "조회";
            this.btnFind.TextHAlign = Infragistics.Win.HAlign.Center;
            this.btnFind.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.btnFind.UpPic = null;
            this.btnFind.UseFlag = true;
            this.btnFind.Click += new System.EventHandler(this.btnFind_Click);
            // 
            // Grid1
            // 
            this.Grid1.AutoScroll = true;
            this.Grid1.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.Grid1.CellClickActionType = Infragistics.Win.UltraWinGrid.CellClickAction.RowSelect;
            this.Grid1.CountRows = 0;
            this.Grid1.DataSource = null;
            this.Grid1.FixedCols = 0;
            this.Grid1.FontSize = 20.25F;
            this.Grid1.GridAutoFitStyle = Infragistics.Win.UltraWinGrid.AutoFitStyle.None;
            this.Grid1.HeaderFontSize = 13F;
            this.Grid1.HeadString = null;
            this.Grid1.Location = new System.Drawing.Point(10, 129);
            this.Grid1.Name = "Grid1";
            this.Grid1.Row = null;
            this.Grid1.ScrollBar = Infragistics.Win.UltraWinGrid.Scrollbars.None;
            this.Grid1.SelectCommand = null;
            this.Grid1.SelectProcedureName = null;
            this.Grid1.Size = new System.Drawing.Size(1250, 650);
            this.Grid1.TabIndex = 64;
            this.Grid1.VAlign = Infragistics.Win.VAlign.Middle;
            // 
            // POP_INV03
            // 
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(1280, 1024);
            this.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.Name = "POP_INV03";
            this.SyncTime = true;
            this.Text = "현장 단말 메인";
            this.Load += new System.EventHandler(this.POP_INV03_Load);
            ((System.ComponentModel.ISupportInitialize)(this.GroupBody)).EndInit();
            this.GroupBody.ResumeLayout(false);
            this.splitContainer1.Panel1.ResumeLayout(false);
            this.splitContainer1.Panel1.PerformLayout();
            this.splitContainer1.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).EndInit();
            this.splitContainer1.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.SplitContainer splitContainer1;
        private ButtonBox bBox1;
        private MESGrid Grid1;
        private MESButton btnFind;
        private System.Windows.Forms.DateTimePicker dtpWorkDate;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Button butWorkDate;
        private System.Windows.Forms.TextBox txtMATNR_NM;
        private System.Windows.Forms.TextBox txtWRK_ORDR;
        private System.Windows.Forms.TextBox txtMATNR;

    }
}
