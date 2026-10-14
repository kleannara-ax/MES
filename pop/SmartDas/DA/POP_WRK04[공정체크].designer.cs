using SmartDas.Components;

namespace SmartDas
{
    partial class POP_WRK04
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(POP_WRK04));
            this.label2 = new System.Windows.Forms.Label();
            this.lblCheckSeq = new SmartDas.Components.MESLabel();
            this.label1 = new System.Windows.Forms.Label();
            this.bBox1 = new SmartDas.Components.ButtonBox();
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.label3 = new System.Windows.Forms.Label();
            this.btnCheckDate = new System.Windows.Forms.Button();
            this.lblCheckTime = new SmartDas.Components.MESLabel();
            this.bCheckList_Down = new SmartDas.Components.MESButton_Top();
            this.bCheckList_Up = new SmartDas.Components.MESButton_Top();
            this.bCheckSeq_Down = new SmartDas.Components.MESButton_Top();
            this.bCheckSeq_Up = new SmartDas.Components.MESButton_Top();
            this.dtpCheckDate = new System.Windows.Forms.DateTimePicker();
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
            this.label2.Text = "체크일자";
            this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblCheckSeq
            // 
            this.lblCheckSeq.BackColor = System.Drawing.Color.White;
            this.lblCheckSeq.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblCheckSeq.ColorContent = System.Drawing.Color.Transparent;
            this.lblCheckSeq.ColorLabel = System.Drawing.Color.White;
            this.lblCheckSeq.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblCheckSeq.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblCheckSeq.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblCheckSeq.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblCheckSeq.Location = new System.Drawing.Point(511, 11);
            this.lblCheckSeq.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblCheckSeq.MoveControl = null;
            this.lblCheckSeq.Name = "lblCheckSeq";
            this.lblCheckSeq.Size = new System.Drawing.Size(100, 50);
            this.lblCheckSeq.TabIndex = 52;
            this.lblCheckSeq.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblCheckSeq.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label1
            // 
            this.label1.BackColor = System.Drawing.Color.Gray;
            this.label1.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label1.ForeColor = System.Drawing.Color.White;
            this.label1.Location = new System.Drawing.Point(385, 11);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(120, 50);
            this.label1.TabIndex = 51;
            this.label1.Text = "체크차수";
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
            this.splitContainer1.Panel1.Controls.Add(this.label3);
            this.splitContainer1.Panel1.Controls.Add(this.btnCheckDate);
            this.splitContainer1.Panel1.Controls.Add(this.lblCheckTime);
            this.splitContainer1.Panel1.Controls.Add(this.bCheckList_Down);
            this.splitContainer1.Panel1.Controls.Add(this.bCheckList_Up);
            this.splitContainer1.Panel1.Controls.Add(this.bCheckSeq_Down);
            this.splitContainer1.Panel1.Controls.Add(this.bCheckSeq_Up);
            this.splitContainer1.Panel1.Controls.Add(this.dtpCheckDate);
            this.splitContainer1.Panel1.Controls.Add(this.Grid1);
            this.splitContainer1.Panel1.Controls.Add(this.label2);
            this.splitContainer1.Panel1.Controls.Add(this.label1);
            this.splitContainer1.Panel1.Controls.Add(this.lblCheckSeq);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.bBox1);
            this.splitContainer1.Size = new System.Drawing.Size(1274, 874);
            this.splitContainer1.SplitterDistance = 789;
            this.splitContainer1.TabIndex = 65;
            // 
            // label3
            // 
            this.label3.BackColor = System.Drawing.Color.Gray;
            this.label3.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label3.ForeColor = System.Drawing.Color.White;
            this.label3.Location = new System.Drawing.Point(738, 11);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(120, 50);
            this.label3.TabIndex = 180;
            this.label3.Text = "검사시간";
            this.label3.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // btnCheckDate
            // 
            this.btnCheckDate.BackgroundImage = global::SmartDas.Properties.Resources.Calendar;
            this.btnCheckDate.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center;
            this.btnCheckDate.CausesValidation = false;
            this.btnCheckDate.FlatAppearance.BorderSize = 0;
            this.btnCheckDate.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(192)))), ((int)(((byte)(192)))));
            this.btnCheckDate.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnCheckDate.Font = new System.Drawing.Font("굴림", 11.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.btnCheckDate.Location = new System.Drawing.Point(317, 13);
            this.btnCheckDate.Name = "btnCheckDate";
            this.btnCheckDate.Size = new System.Drawing.Size(46, 46);
            this.btnCheckDate.TabIndex = 179;
            this.btnCheckDate.UseVisualStyleBackColor = false;
            this.btnCheckDate.Click += new System.EventHandler(this.btnCheckDate_Click);
            // 
            // lblCheckTime
            // 
            this.lblCheckTime.BackColor = System.Drawing.Color.White;
            this.lblCheckTime.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblCheckTime.ColorContent = System.Drawing.Color.Transparent;
            this.lblCheckTime.ColorLabel = System.Drawing.Color.White;
            this.lblCheckTime.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblCheckTime.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblCheckTime.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblCheckTime.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblCheckTime.Location = new System.Drawing.Point(866, 11);
            this.lblCheckTime.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblCheckTime.MoveControl = null;
            this.lblCheckTime.Name = "lblCheckTime";
            this.lblCheckTime.Size = new System.Drawing.Size(120, 50);
            this.lblCheckTime.TabIndex = 172;
            this.lblCheckTime.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblCheckTime.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblCheckTime.Click += new System.EventHandler(this.lblCheckTime_Click);
            // 
            // bCheckList_Down
            // 
            this.bCheckList_Down.AlarmColor = System.Drawing.Color.IndianRed;
            this.bCheckList_Down.BackColor = System.Drawing.Color.Transparent;
            this.bCheckList_Down.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.bCheckList_Down.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("bCheckList_Down.BackgroundImage")));
            this.bCheckList_Down.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.bCheckList_Down.ButtonClickType = SmartDas.Components.MESButton_Top.ButtonClickTypeEnum.Click;
            this.bCheckList_Down.ButtonPressed = false;
            this.bCheckList_Down.ClickBackColor = System.Drawing.Color.Transparent;
            this.bCheckList_Down.ExTag = null;
            this.bCheckList_Down.Font = new System.Drawing.Font("맑은 고딕", 24F);
            this.bCheckList_Down.FontSize = 24F;
            this.bCheckList_Down.LinkButtonBox = null;
            this.bCheckList_Down.LinkGrid = null;
            this.bCheckList_Down.LinkMoveSize = 0;
            this.bCheckList_Down.LinkType = SmartDas.Components.MESButton_Top.LinkGridButtonType.Down;
            this.bCheckList_Down.Location = new System.Drawing.Point(1209, 11);
            this.bCheckList_Down.Margin = new System.Windows.Forms.Padding(0);
            this.bCheckList_Down.Name = "bCheckList_Down";
            this.bCheckList_Down.ParentBox = null;
            this.bCheckList_Down.Size = new System.Drawing.Size(50, 50);
            this.bCheckList_Down.TabIndex = 171;
            this.bCheckList_Down.TextHAlign = Infragistics.Win.HAlign.Center;
            this.bCheckList_Down.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.bCheckList_Down.UseFlag = true;
            // 
            // bCheckList_Up
            // 
            this.bCheckList_Up.AlarmColor = System.Drawing.Color.IndianRed;
            this.bCheckList_Up.BackColor = System.Drawing.Color.Transparent;
            this.bCheckList_Up.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.bCheckList_Up.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("bCheckList_Up.BackgroundImage")));
            this.bCheckList_Up.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.bCheckList_Up.ButtonClickType = SmartDas.Components.MESButton_Top.ButtonClickTypeEnum.Click;
            this.bCheckList_Up.ButtonPressed = false;
            this.bCheckList_Up.ClickBackColor = System.Drawing.Color.Transparent;
            this.bCheckList_Up.ExTag = null;
            this.bCheckList_Up.Font = new System.Drawing.Font("맑은 고딕", 24F);
            this.bCheckList_Up.FontSize = 24F;
            this.bCheckList_Up.LinkButtonBox = null;
            this.bCheckList_Up.LinkGrid = null;
            this.bCheckList_Up.LinkMoveSize = 0;
            this.bCheckList_Up.LinkType = SmartDas.Components.MESButton_Top.LinkGridButtonType.Up;
            this.bCheckList_Up.Location = new System.Drawing.Point(1153, 11);
            this.bCheckList_Up.Margin = new System.Windows.Forms.Padding(0);
            this.bCheckList_Up.Name = "bCheckList_Up";
            this.bCheckList_Up.ParentBox = null;
            this.bCheckList_Up.Size = new System.Drawing.Size(50, 50);
            this.bCheckList_Up.TabIndex = 170;
            this.bCheckList_Up.TextHAlign = Infragistics.Win.HAlign.Center;
            this.bCheckList_Up.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.bCheckList_Up.UseFlag = true;
            // 
            // bCheckSeq_Down
            // 
            this.bCheckSeq_Down.AlarmColor = System.Drawing.Color.IndianRed;
            this.bCheckSeq_Down.BackColor = System.Drawing.Color.Transparent;
            this.bCheckSeq_Down.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.bCheckSeq_Down.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("bCheckSeq_Down.BackgroundImage")));
            this.bCheckSeq_Down.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.bCheckSeq_Down.ButtonClickType = SmartDas.Components.MESButton_Top.ButtonClickTypeEnum.Click;
            this.bCheckSeq_Down.ButtonPressed = false;
            this.bCheckSeq_Down.ClickBackColor = System.Drawing.Color.Transparent;
            this.bCheckSeq_Down.ExTag = null;
            this.bCheckSeq_Down.Font = new System.Drawing.Font("맑은 고딕", 24F);
            this.bCheckSeq_Down.FontSize = 24F;
            this.bCheckSeq_Down.LinkButtonBox = null;
            this.bCheckSeq_Down.LinkGrid = null;
            this.bCheckSeq_Down.LinkMoveSize = 0;
            this.bCheckSeq_Down.LinkType = SmartDas.Components.MESButton_Top.LinkGridButtonType.Down;
            this.bCheckSeq_Down.Location = new System.Drawing.Point(672, 11);
            this.bCheckSeq_Down.Margin = new System.Windows.Forms.Padding(0);
            this.bCheckSeq_Down.Name = "bCheckSeq_Down";
            this.bCheckSeq_Down.ParentBox = null;
            this.bCheckSeq_Down.Size = new System.Drawing.Size(50, 50);
            this.bCheckSeq_Down.TabIndex = 169;
            this.bCheckSeq_Down.Tag = "-1";
            this.bCheckSeq_Down.TextHAlign = Infragistics.Win.HAlign.Center;
            this.bCheckSeq_Down.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.bCheckSeq_Down.UseFlag = true;
            this.bCheckSeq_Down.Click += new System.EventHandler(this.bCheckSeq_Down_Click);
            // 
            // bCheckSeq_Up
            // 
            this.bCheckSeq_Up.AlarmColor = System.Drawing.Color.IndianRed;
            this.bCheckSeq_Up.BackColor = System.Drawing.Color.Transparent;
            this.bCheckSeq_Up.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.bCheckSeq_Up.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("bCheckSeq_Up.BackgroundImage")));
            this.bCheckSeq_Up.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.bCheckSeq_Up.ButtonClickType = SmartDas.Components.MESButton_Top.ButtonClickTypeEnum.Click;
            this.bCheckSeq_Up.ButtonPressed = false;
            this.bCheckSeq_Up.ClickBackColor = System.Drawing.Color.Transparent;
            this.bCheckSeq_Up.ExTag = null;
            this.bCheckSeq_Up.Font = new System.Drawing.Font("맑은 고딕", 24F);
            this.bCheckSeq_Up.FontSize = 24F;
            this.bCheckSeq_Up.LinkButtonBox = null;
            this.bCheckSeq_Up.LinkGrid = null;
            this.bCheckSeq_Up.LinkMoveSize = 0;
            this.bCheckSeq_Up.LinkType = SmartDas.Components.MESButton_Top.LinkGridButtonType.Up;
            this.bCheckSeq_Up.Location = new System.Drawing.Point(616, 11);
            this.bCheckSeq_Up.Margin = new System.Windows.Forms.Padding(0);
            this.bCheckSeq_Up.Name = "bCheckSeq_Up";
            this.bCheckSeq_Up.ParentBox = null;
            this.bCheckSeq_Up.Size = new System.Drawing.Size(50, 50);
            this.bCheckSeq_Up.TabIndex = 168;
            this.bCheckSeq_Up.Tag = "1";
            this.bCheckSeq_Up.TextHAlign = Infragistics.Win.HAlign.Center;
            this.bCheckSeq_Up.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.bCheckSeq_Up.UseFlag = true;
            this.bCheckSeq_Up.Click += new System.EventHandler(this.bCheckSeq_Up_Click);
            // 
            // dtpCheckDate
            // 
            this.dtpCheckDate.CalendarFont = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.dtpCheckDate.CustomFormat = "yyyy-MM-dd";
            this.dtpCheckDate.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.dtpCheckDate.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtpCheckDate.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.dtpCheckDate.Location = new System.Drawing.Point(135, 11);
            this.dtpCheckDate.MinimumSize = new System.Drawing.Size(0, 50);
            this.dtpCheckDate.Name = "dtpCheckDate";
            this.dtpCheckDate.ShowCheckBox = true;
            this.dtpCheckDate.Size = new System.Drawing.Size(230, 50);
            this.dtpCheckDate.TabIndex = 124;
            this.dtpCheckDate.ValueChanged += new System.EventHandler(this.cboOrderDate_ValueChanged);
            this.dtpCheckDate.DropDown += new System.EventHandler(this.dtpDate_DropDown);
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
            this.Grid1.Location = new System.Drawing.Point(9, 72);
            this.Grid1.Name = "Grid1";
            this.Grid1.Row = null;
            this.Grid1.ScrollBar = Infragistics.Win.UltraWinGrid.Scrollbars.None;
            this.Grid1.SelectCommand = null;
            this.Grid1.SelectProcedureName = null;
            this.Grid1.Size = new System.Drawing.Size(1250, 700);
            this.Grid1.TabIndex = 64;
            this.Grid1.VAlign = Infragistics.Win.VAlign.Middle;
            this.Grid1.ClickCellButton += new SmartDas.Components.MESGrid.gridClickCellButton(this.Grid1_ClickCellButton);
            // 
            // POP_WRK04
            // 
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(1280, 1024);
            this.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.Name = "POP_WRK04";
            this.SyncTime = true;
            this.Text = "현장 단말 메인";
            this.Load += new System.EventHandler(this.POP_WRK04_Load);
            ((System.ComponentModel.ISupportInitialize)(this.GroupBody)).EndInit();
            this.GroupBody.ResumeLayout(false);
            this.splitContainer1.Panel1.ResumeLayout(false);
            this.splitContainer1.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).EndInit();
            this.splitContainer1.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Label label2;
        private MESLabel lblCheckSeq;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.SplitContainer splitContainer1;
        private ButtonBox bBox1;
        private MESGrid Grid1;
        private System.Windows.Forms.DateTimePicker dtpCheckDate;
        protected MESButton_Top bCheckSeq_Down;
        protected MESButton_Top bCheckSeq_Up;
        protected MESButton_Top bCheckList_Down;
        protected MESButton_Top bCheckList_Up;
        private MESLabel lblCheckTime;
        private System.Windows.Forms.Button btnCheckDate;
        private System.Windows.Forms.Label label3;

    }
}
