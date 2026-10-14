using SmartDas.Components;

namespace SmartDas
{
    partial class POP_WRK01
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(POP_WRK01));
            this.label2 = new System.Windows.Forms.Label();
            this.bBox1 = new SmartDas.Components.ButtonBox();
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.txtBS_WGT = new System.Windows.Forms.TextBox();
            this.txtPCODE = new System.Windows.Forms.TextBox();
            this.txtIND_BCD = new System.Windows.Forms.TextBox();
            this.txtORDER_NO = new System.Windows.Forms.TextBox();
            this.lblLabel3 = new System.Windows.Forms.Label();
            this.lblLabel4 = new System.Windows.Forms.Label();
            this.lblLabel5 = new System.Windows.Forms.Label();
            this.lblLabel2 = new System.Windows.Forms.Label();
            this.lblLocation = new SmartDas.Components.MESLabel();
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
            this.label2.Font = new System.Drawing.Font("맑은 고딕", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label2.ForeColor = System.Drawing.Color.White;
            this.label2.Location = new System.Drawing.Point(9, 12);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(118, 33);
            this.label2.TabIndex = 49;
            this.label2.Text = "대기로케이션";
            this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
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
            this.splitContainer1.Panel1.Controls.Add(this.txtBS_WGT);
            this.splitContainer1.Panel1.Controls.Add(this.txtPCODE);
            this.splitContainer1.Panel1.Controls.Add(this.txtIND_BCD);
            this.splitContainer1.Panel1.Controls.Add(this.txtORDER_NO);
            this.splitContainer1.Panel1.Controls.Add(this.lblLabel3);
            this.splitContainer1.Panel1.Controls.Add(this.lblLabel4);
            this.splitContainer1.Panel1.Controls.Add(this.lblLabel5);
            this.splitContainer1.Panel1.Controls.Add(this.lblLabel2);
            this.splitContainer1.Panel1.Controls.Add(this.lblLocation);
            this.splitContainer1.Panel1.Controls.Add(this.btnFind);
            this.splitContainer1.Panel1.Controls.Add(this.Grid1);
            this.splitContainer1.Panel1.Controls.Add(this.label2);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.bBox1);
            this.splitContainer1.Size = new System.Drawing.Size(1274, 874);
            this.splitContainer1.SplitterDistance = 789;
            this.splitContainer1.TabIndex = 65;
            // 
            // txtBS_WGT
            // 
            this.txtBS_WGT.BackColor = System.Drawing.SystemColors.Window;
            this.txtBS_WGT.CharacterCasing = System.Windows.Forms.CharacterCasing.Upper;
            this.txtBS_WGT.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtBS_WGT.ImeMode = System.Windows.Forms.ImeMode.Off;
            this.txtBS_WGT.Location = new System.Drawing.Point(1001, 12);
            this.txtBS_WGT.MaxLength = 10;
            this.txtBS_WGT.Name = "txtBS_WGT";
            this.txtBS_WGT.Size = new System.Drawing.Size(90, 32);
            this.txtBS_WGT.TabIndex = 298;
            this.txtBS_WGT.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            // 
            // txtPCODE
            // 
            this.txtPCODE.BackColor = System.Drawing.SystemColors.Window;
            this.txtPCODE.CharacterCasing = System.Windows.Forms.CharacterCasing.Upper;
            this.txtPCODE.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtPCODE.ImeMode = System.Windows.Forms.ImeMode.Off;
            this.txtPCODE.Location = new System.Drawing.Point(816, 12);
            this.txtPCODE.MaxLength = 10;
            this.txtPCODE.Name = "txtPCODE";
            this.txtPCODE.Size = new System.Drawing.Size(90, 32);
            this.txtPCODE.TabIndex = 297;
            this.txtPCODE.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            // 
            // txtIND_BCD
            // 
            this.txtIND_BCD.BackColor = System.Drawing.SystemColors.Window;
            this.txtIND_BCD.CharacterCasing = System.Windows.Forms.CharacterCasing.Upper;
            this.txtIND_BCD.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtIND_BCD.ImeMode = System.Windows.Forms.ImeMode.Off;
            this.txtIND_BCD.Location = new System.Drawing.Point(564, 12);
            this.txtIND_BCD.MaxLength = 10;
            this.txtIND_BCD.Name = "txtIND_BCD";
            this.txtIND_BCD.Size = new System.Drawing.Size(136, 32);
            this.txtIND_BCD.TabIndex = 296;
            this.txtIND_BCD.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            // 
            // txtORDER_NO
            // 
            this.txtORDER_NO.BackColor = System.Drawing.SystemColors.Window;
            this.txtORDER_NO.CharacterCasing = System.Windows.Forms.CharacterCasing.Upper;
            this.txtORDER_NO.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtORDER_NO.ImeMode = System.Windows.Forms.ImeMode.Off;
            this.txtORDER_NO.Location = new System.Drawing.Point(333, 12);
            this.txtORDER_NO.MaxLength = 10;
            this.txtORDER_NO.Name = "txtORDER_NO";
            this.txtORDER_NO.Size = new System.Drawing.Size(136, 32);
            this.txtORDER_NO.TabIndex = 295;
            this.txtORDER_NO.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            // 
            // lblLabel3
            // 
            this.lblLabel3.BackColor = System.Drawing.Color.Gray;
            this.lblLabel3.Font = new System.Drawing.Font("맑은 고딕", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblLabel3.ForeColor = System.Drawing.Color.White;
            this.lblLabel3.Location = new System.Drawing.Point(914, 12);
            this.lblLabel3.Name = "lblLabel3";
            this.lblLabel3.Size = new System.Drawing.Size(80, 32);
            this.lblLabel3.TabIndex = 292;
            this.lblLabel3.Text = "평량";
            this.lblLabel3.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblLabel4
            // 
            this.lblLabel4.BackColor = System.Drawing.Color.Gray;
            this.lblLabel4.Font = new System.Drawing.Font("맑은 고딕", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblLabel4.ForeColor = System.Drawing.Color.White;
            this.lblLabel4.Location = new System.Drawing.Point(249, 12);
            this.lblLabel4.Name = "lblLabel4";
            this.lblLabel4.Size = new System.Drawing.Size(80, 32);
            this.lblLabel4.TabIndex = 293;
            this.lblLabel4.Text = "오더번호";
            this.lblLabel4.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblLabel5
            // 
            this.lblLabel5.BackColor = System.Drawing.Color.Gray;
            this.lblLabel5.Font = new System.Drawing.Font("맑은 고딕", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblLabel5.ForeColor = System.Drawing.Color.White;
            this.lblLabel5.Location = new System.Drawing.Point(478, 12);
            this.lblLabel5.Name = "lblLabel5";
            this.lblLabel5.Size = new System.Drawing.Size(80, 32);
            this.lblLabel5.TabIndex = 294;
            this.lblLabel5.Text = "바코드";
            this.lblLabel5.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblLabel2
            // 
            this.lblLabel2.BackColor = System.Drawing.Color.Gray;
            this.lblLabel2.Font = new System.Drawing.Font("맑은 고딕", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblLabel2.ForeColor = System.Drawing.Color.White;
            this.lblLabel2.Location = new System.Drawing.Point(710, 12);
            this.lblLabel2.Name = "lblLabel2";
            this.lblLabel2.Size = new System.Drawing.Size(100, 32);
            this.lblLabel2.TabIndex = 291;
            this.lblLabel2.Text = "지종코드";
            this.lblLabel2.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblLocation
            // 
            this.lblLocation.BackColor = System.Drawing.Color.White;
            this.lblLocation.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblLocation.ColorContent = System.Drawing.Color.Transparent;
            this.lblLocation.ColorLabel = System.Drawing.Color.White;
            this.lblLocation.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblLocation.Font = new System.Drawing.Font("맑은 고딕", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblLocation.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblLocation.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblLocation.Location = new System.Drawing.Point(132, 12);
            this.lblLocation.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblLocation.MoveControl = null;
            this.lblLocation.Name = "lblLocation";
            this.lblLocation.Size = new System.Drawing.Size(101, 33);
            this.lblLocation.TabIndex = 126;
            this.lblLocation.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblLocation.TextVAlign = Infragistics.Win.VAlign.Middle;
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
            this.btnFind.Location = new System.Drawing.Point(1127, 12);
            this.btnFind.Margin = new System.Windows.Forms.Padding(0);
            this.btnFind.MaximumSize = new System.Drawing.Size(300, 300);
            this.btnFind.Name = "btnFind";
            this.btnFind.ParentBox = null;
            this.btnFind.Size = new System.Drawing.Size(132, 33);
            this.btnFind.TabIndex = 125;
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
            this.Grid1.Location = new System.Drawing.Point(9, 53);
            this.Grid1.Name = "Grid1";
            this.Grid1.Row = null;
            this.Grid1.ScrollBar = Infragistics.Win.UltraWinGrid.Scrollbars.None;
            this.Grid1.SelectCommand = null;
            this.Grid1.SelectProcedureName = null;
            this.Grid1.Size = new System.Drawing.Size(1250, 719);
            this.Grid1.TabIndex = 64;
            this.Grid1.VAlign = Infragistics.Win.VAlign.Middle;
            this.Grid1.ClickCellButton += new SmartDas.Components.MESGrid.gridClickCellButton(this.Grid1_ClickCellButton);
            // 
            // POP_WRK01
            // 
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(1280, 1024);
            this.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.Name = "POP_WRK01";
            this.SyncTime = true;
            this.Text = "현장 단말 메인";
            this.Load += new System.EventHandler(this.POP_WRK01_Load);
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
        private System.Windows.Forms.SplitContainer splitContainer1;
        private ButtonBox bBox1;
        private MESGrid Grid1;
        private MESButton btnFind;
        private MESLabel lblLocation;
        private System.Windows.Forms.TextBox txtBS_WGT;
        private System.Windows.Forms.TextBox txtPCODE;
        private System.Windows.Forms.TextBox txtIND_BCD;
        private System.Windows.Forms.TextBox txtORDER_NO;
        private System.Windows.Forms.Label lblLabel3;
        private System.Windows.Forms.Label lblLabel4;
        private System.Windows.Forms.Label lblLabel5;
        private System.Windows.Forms.Label lblLabel2;

    }
}
