using SmartDas.Components;

namespace SmartDas
{
    partial class POP_WRK12
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
            this.label2 = new System.Windows.Forms.Label();
            this.lblMATNR = new SmartDas.Components.MESLabel();
            this.label1 = new System.Windows.Forms.Label();
            this.lblSPEC = new SmartDas.Components.MESLabel();
            this.label3 = new System.Windows.Forms.Label();
            this.bBox1 = new SmartDas.Components.ButtonBox();
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.lblMulCnt = new SmartDas.Components.MESLabel();
            this.lblBSWGT = new SmartDas.Components.MESLabel();
            this.lblPRFM_DT = new SmartDas.Components.MESLabel();
            this.txtRMK = new System.Windows.Forms.TextBox();
            this.PRD_END_DATE = new System.Windows.Forms.Button();
            this.butPRD_STR_DATE = new System.Windows.Forms.Button();
            this.label17 = new System.Windows.Forms.Label();
            this.label16 = new System.Windows.Forms.Label();
            this.lblWorkSpeed = new SmartDas.Components.MESLabel();
            this.label15 = new System.Windows.Forms.Label();
            this.lblTM = new SmartDas.Components.MESLabel();
            this.label14 = new System.Windows.Forms.Label();
            this.lblWGT = new SmartDas.Components.MESLabel();
            this.label12 = new System.Windows.Forms.Label();
            this.lblROLLCNT = new SmartDas.Components.MESLabel();
            this.lblPRD_END_TIME = new SmartDas.Components.MESLabel();
            this.dtpPRD_END_DATE = new System.Windows.Forms.DateTimePicker();
            this.label11 = new System.Windows.Forms.Label();
            this.label10 = new System.Windows.Forms.Label();
            this.lblWorkWidth = new SmartDas.Components.MESLabel();
            this.lblPRD_STR_DATE = new SmartDas.Components.MESLabel();
            this.dtpPRD_STR_DATE = new System.Windows.Forms.DateTimePicker();
            this.label9 = new System.Windows.Forms.Label();
            this.label13 = new System.Windows.Forms.Label();
            this.label8 = new System.Windows.Forms.Label();
            this.label7 = new System.Windows.Forms.Label();
            this.label6 = new System.Windows.Forms.Label();
            this.lblWRK_ORDR_RMK = new SmartDas.Components.MESLabel();
            this.label5 = new System.Windows.Forms.Label();
            this.lblWRK_ORDR_NO = new SmartDas.Components.MESLabel();
            this.label4 = new System.Windows.Forms.Label();
            this.lblORDER_QTY = new SmartDas.Components.MESLabel();
            this.lblPRD_REQ_DT = new SmartDas.Components.MESLabel();
            this.lblWRK_ORDR_SEQNO = new SmartDas.Components.MESLabel();
            this.lblMATNR_SPEC = new SmartDas.Components.MESLabel();
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
            // label2
            // 
            this.label2.BackColor = System.Drawing.Color.Gray;
            this.label2.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label2.ForeColor = System.Drawing.Color.White;
            this.label2.Location = new System.Drawing.Point(15, 76);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(150, 50);
            this.label2.TabIndex = 49;
            this.label2.Text = "생산요청일";
            this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblMATNR
            // 
            this.lblMATNR.BackColor = System.Drawing.Color.LightGray;
            this.lblMATNR.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblMATNR.ColorContent = System.Drawing.Color.Transparent;
            this.lblMATNR.ColorLabel = System.Drawing.Color.LightGray;
            this.lblMATNR.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblMATNR.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblMATNR.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblMATNR.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblMATNR.Location = new System.Drawing.Point(171, 190);
            this.lblMATNR.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblMATNR.MoveControl = null;
            this.lblMATNR.Name = "lblMATNR";
            this.lblMATNR.Size = new System.Drawing.Size(670, 50);
            this.lblMATNR.TabIndex = 52;
            this.lblMATNR.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblMATNR.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label1
            // 
            this.label1.BackColor = System.Drawing.Color.Gray;
            this.label1.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label1.ForeColor = System.Drawing.Color.White;
            this.label1.Location = new System.Drawing.Point(15, 190);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(150, 50);
            this.label1.TabIndex = 51;
            this.label1.Text = "품목/규격";
            this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblSPEC
            // 
            this.lblSPEC.BackColor = System.Drawing.Color.LightGray;
            this.lblSPEC.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblSPEC.ColorContent = System.Drawing.Color.Transparent;
            this.lblSPEC.ColorLabel = System.Drawing.Color.LightGray;
            this.lblSPEC.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblSPEC.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblSPEC.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblSPEC.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblSPEC.Location = new System.Drawing.Point(171, 247);
            this.lblSPEC.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblSPEC.MoveControl = null;
            this.lblSPEC.Name = "lblSPEC";
            this.lblSPEC.Size = new System.Drawing.Size(1085, 50);
            this.lblSPEC.TabIndex = 55;
            this.lblSPEC.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblSPEC.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label3
            // 
            this.label3.BackColor = System.Drawing.Color.Gray;
            this.label3.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label3.ForeColor = System.Drawing.Color.White;
            this.label3.Location = new System.Drawing.Point(15, 247);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(150, 50);
            this.label3.TabIndex = 54;
            this.label3.Text = "지폭";
            this.label3.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
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
            this.splitContainer1.Panel1.Controls.Add(this.lblMulCnt);
            this.splitContainer1.Panel1.Controls.Add(this.lblBSWGT);
            this.splitContainer1.Panel1.Controls.Add(this.lblPRFM_DT);
            this.splitContainer1.Panel1.Controls.Add(this.txtRMK);
            this.splitContainer1.Panel1.Controls.Add(this.PRD_END_DATE);
            this.splitContainer1.Panel1.Controls.Add(this.butPRD_STR_DATE);
            this.splitContainer1.Panel1.Controls.Add(this.label17);
            this.splitContainer1.Panel1.Controls.Add(this.label16);
            this.splitContainer1.Panel1.Controls.Add(this.lblWorkSpeed);
            this.splitContainer1.Panel1.Controls.Add(this.label15);
            this.splitContainer1.Panel1.Controls.Add(this.lblTM);
            this.splitContainer1.Panel1.Controls.Add(this.label14);
            this.splitContainer1.Panel1.Controls.Add(this.lblWGT);
            this.splitContainer1.Panel1.Controls.Add(this.label12);
            this.splitContainer1.Panel1.Controls.Add(this.lblROLLCNT);
            this.splitContainer1.Panel1.Controls.Add(this.lblPRD_END_TIME);
            this.splitContainer1.Panel1.Controls.Add(this.dtpPRD_END_DATE);
            this.splitContainer1.Panel1.Controls.Add(this.label11);
            this.splitContainer1.Panel1.Controls.Add(this.label10);
            this.splitContainer1.Panel1.Controls.Add(this.lblWorkWidth);
            this.splitContainer1.Panel1.Controls.Add(this.lblPRD_STR_DATE);
            this.splitContainer1.Panel1.Controls.Add(this.dtpPRD_STR_DATE);
            this.splitContainer1.Panel1.Controls.Add(this.label9);
            this.splitContainer1.Panel1.Controls.Add(this.label13);
            this.splitContainer1.Panel1.Controls.Add(this.label8);
            this.splitContainer1.Panel1.Controls.Add(this.label7);
            this.splitContainer1.Panel1.Controls.Add(this.label6);
            this.splitContainer1.Panel1.Controls.Add(this.lblWRK_ORDR_RMK);
            this.splitContainer1.Panel1.Controls.Add(this.label5);
            this.splitContainer1.Panel1.Controls.Add(this.lblWRK_ORDR_NO);
            this.splitContainer1.Panel1.Controls.Add(this.label4);
            this.splitContainer1.Panel1.Controls.Add(this.lblORDER_QTY);
            this.splitContainer1.Panel1.Controls.Add(this.lblPRD_REQ_DT);
            this.splitContainer1.Panel1.Controls.Add(this.lblWRK_ORDR_SEQNO);
            this.splitContainer1.Panel1.Controls.Add(this.lblMATNR_SPEC);
            this.splitContainer1.Panel1.Controls.Add(this.label2);
            this.splitContainer1.Panel1.Controls.Add(this.label1);
            this.splitContainer1.Panel1.Controls.Add(this.lblMATNR);
            this.splitContainer1.Panel1.Controls.Add(this.label3);
            this.splitContainer1.Panel1.Controls.Add(this.lblSPEC);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.bBox1);
            this.splitContainer1.Size = new System.Drawing.Size(1274, 874);
            this.splitContainer1.SplitterDistance = 789;
            this.splitContainer1.TabIndex = 65;
            // 
            // lblMulCnt
            // 
            this.lblMulCnt.BackColor = System.Drawing.Color.White;
            this.lblMulCnt.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblMulCnt.ColorContent = System.Drawing.Color.Transparent;
            this.lblMulCnt.ColorLabel = System.Drawing.Color.White;
            this.lblMulCnt.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblMulCnt.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblMulCnt.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblMulCnt.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblMulCnt.Location = new System.Drawing.Point(169, 551);
            this.lblMulCnt.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblMulCnt.MoveControl = null;
            this.lblMulCnt.Name = "lblMulCnt";
            this.lblMulCnt.Size = new System.Drawing.Size(196, 50);
            this.lblMulCnt.TabIndex = 228;
            this.lblMulCnt.Text = "1";
            this.lblMulCnt.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblMulCnt.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblMulCnt.Visible = false;
            this.lblMulCnt.Click += new System.EventHandler(this.lblMulCnt_Click);
            // 
            // lblBSWGT
            // 
            this.lblBSWGT.BackColor = System.Drawing.Color.LightGray;
            this.lblBSWGT.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblBSWGT.ColorContent = System.Drawing.Color.Transparent;
            this.lblBSWGT.ColorLabel = System.Drawing.Color.LightGray;
            this.lblBSWGT.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblBSWGT.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblBSWGT.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblBSWGT.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblBSWGT.Location = new System.Drawing.Point(170, 494);
            this.lblBSWGT.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblBSWGT.MoveControl = null;
            this.lblBSWGT.Name = "lblBSWGT";
            this.lblBSWGT.Size = new System.Drawing.Size(195, 50);
            this.lblBSWGT.TabIndex = 227;
            this.lblBSWGT.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblBSWGT.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblPRFM_DT
            // 
            this.lblPRFM_DT.BackColor = System.Drawing.Color.LightGray;
            this.lblPRFM_DT.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblPRFM_DT.ColorContent = System.Drawing.Color.Transparent;
            this.lblPRFM_DT.ColorLabel = System.Drawing.Color.LightGray;
            this.lblPRFM_DT.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblPRFM_DT.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPRFM_DT.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblPRFM_DT.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPRFM_DT.Location = new System.Drawing.Point(170, 437);
            this.lblPRFM_DT.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPRFM_DT.MoveControl = null;
            this.lblPRFM_DT.Name = "lblPRFM_DT";
            this.lblPRFM_DT.Size = new System.Drawing.Size(400, 50);
            this.lblPRFM_DT.TabIndex = 226;
            this.lblPRFM_DT.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblPRFM_DT.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // txtRMK
            // 
            this.txtRMK.Font = new System.Drawing.Font("맑은 고딕", 20.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtRMK.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.txtRMK.Location = new System.Drawing.Point(170, 664);
            this.txtRMK.MinimumSize = new System.Drawing.Size(1085, 110);
            this.txtRMK.Name = "txtRMK";
            this.txtRMK.Size = new System.Drawing.Size(1085, 110);
            this.txtRMK.TabIndex = 225;
            // 
            // PRD_END_DATE
            // 
            this.PRD_END_DATE.BackgroundImage = global::SmartDas.Properties.Resources.Calendar;
            this.PRD_END_DATE.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center;
            this.PRD_END_DATE.CausesValidation = false;
            this.PRD_END_DATE.FlatAppearance.BorderSize = 0;
            this.PRD_END_DATE.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(192)))), ((int)(((byte)(192)))));
            this.PRD_END_DATE.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.PRD_END_DATE.Font = new System.Drawing.Font("굴림", 11.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.PRD_END_DATE.Location = new System.Drawing.Point(1014, 496);
            this.PRD_END_DATE.Name = "PRD_END_DATE";
            this.PRD_END_DATE.Size = new System.Drawing.Size(46, 46);
            this.PRD_END_DATE.TabIndex = 223;
            this.PRD_END_DATE.Tag = "endDate";
            this.PRD_END_DATE.UseVisualStyleBackColor = false;
            this.PRD_END_DATE.Click += new System.EventHandler(this.butWorkDate_Click);
            // 
            // butPRD_STR_DATE
            // 
            this.butPRD_STR_DATE.BackgroundImage = global::SmartDas.Properties.Resources.Calendar;
            this.butPRD_STR_DATE.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center;
            this.butPRD_STR_DATE.CausesValidation = false;
            this.butPRD_STR_DATE.FlatAppearance.BorderSize = 0;
            this.butPRD_STR_DATE.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(192)))), ((int)(((byte)(192)))));
            this.butPRD_STR_DATE.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.butPRD_STR_DATE.Font = new System.Drawing.Font("굴림", 11.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.butPRD_STR_DATE.Location = new System.Drawing.Point(1014, 440);
            this.butPRD_STR_DATE.Name = "butPRD_STR_DATE";
            this.butPRD_STR_DATE.Size = new System.Drawing.Size(46, 46);
            this.butPRD_STR_DATE.TabIndex = 222;
            this.butPRD_STR_DATE.Tag = "startDate";
            this.butPRD_STR_DATE.UseVisualStyleBackColor = false;
            this.butPRD_STR_DATE.Click += new System.EventHandler(this.butWorkDate_Click);
            // 
            // label17
            // 
            this.label17.BackColor = System.Drawing.Color.Gray;
            this.label17.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label17.ForeColor = System.Drawing.Color.White;
            this.label17.Location = new System.Drawing.Point(15, 663);
            this.label17.Name = "label17";
            this.label17.Size = new System.Drawing.Size(150, 110);
            this.label17.TabIndex = 219;
            this.label17.Text = "비고";
            this.label17.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label16
            // 
            this.label16.BackColor = System.Drawing.Color.Gray;
            this.label16.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label16.ForeColor = System.Drawing.Color.White;
            this.label16.Location = new System.Drawing.Point(586, 606);
            this.label16.Name = "label16";
            this.label16.Size = new System.Drawing.Size(150, 50);
            this.label16.TabIndex = 217;
            this.label16.Text = "선속(M/분)";
            this.label16.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblWorkSpeed
            // 
            this.lblWorkSpeed.BackColor = System.Drawing.Color.LightGray;
            this.lblWorkSpeed.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblWorkSpeed.ColorContent = System.Drawing.Color.Transparent;
            this.lblWorkSpeed.ColorLabel = System.Drawing.Color.LightGray;
            this.lblWorkSpeed.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblWorkSpeed.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWorkSpeed.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblWorkSpeed.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWorkSpeed.Location = new System.Drawing.Point(745, 607);
            this.lblWorkSpeed.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWorkSpeed.MoveControl = null;
            this.lblWorkSpeed.Name = "lblWorkSpeed";
            this.lblWorkSpeed.Size = new System.Drawing.Size(510, 50);
            this.lblWorkSpeed.TabIndex = 218;
            this.lblWorkSpeed.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblWorkSpeed.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label15
            // 
            this.label15.BackColor = System.Drawing.Color.Gray;
            this.label15.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label15.ForeColor = System.Drawing.Color.White;
            this.label15.Location = new System.Drawing.Point(586, 550);
            this.label15.Name = "label15";
            this.label15.Size = new System.Drawing.Size(150, 50);
            this.label15.TabIndex = 215;
            this.label15.Text = "가동시간(분)";
            this.label15.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblTM
            // 
            this.lblTM.BackColor = System.Drawing.Color.LightGray;
            this.lblTM.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblTM.ColorContent = System.Drawing.Color.Transparent;
            this.lblTM.ColorLabel = System.Drawing.Color.LightGray;
            this.lblTM.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblTM.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblTM.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblTM.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblTM.Location = new System.Drawing.Point(745, 551);
            this.lblTM.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblTM.MoveControl = null;
            this.lblTM.Name = "lblTM";
            this.lblTM.Size = new System.Drawing.Size(510, 50);
            this.lblTM.TabIndex = 216;
            this.lblTM.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblTM.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label14
            // 
            this.label14.BackColor = System.Drawing.Color.Gray;
            this.label14.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label14.ForeColor = System.Drawing.Color.White;
            this.label14.Location = new System.Drawing.Point(15, 607);
            this.label14.Name = "label14";
            this.label14.Size = new System.Drawing.Size(150, 50);
            this.label14.TabIndex = 213;
            this.label14.Text = "중량(Kg)";
            this.label14.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblWGT
            // 
            this.lblWGT.BackColor = System.Drawing.Color.White;
            this.lblWGT.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblWGT.ColorContent = System.Drawing.Color.Transparent;
            this.lblWGT.ColorLabel = System.Drawing.Color.White;
            this.lblWGT.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblWGT.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWGT.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblWGT.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWGT.Location = new System.Drawing.Point(169, 608);
            this.lblWGT.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWGT.MoveControl = null;
            this.lblWGT.Name = "lblWGT";
            this.lblWGT.Size = new System.Drawing.Size(402, 50);
            this.lblWGT.TabIndex = 214;
            this.lblWGT.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblWGT.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblWGT.Click += new System.EventHandler(this.lblWGT_Click);
            // 
            // label12
            // 
            this.label12.BackColor = System.Drawing.Color.Gray;
            this.label12.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label12.ForeColor = System.Drawing.Color.White;
            this.label12.Location = new System.Drawing.Point(15, 551);
            this.label12.Name = "label12";
            this.label12.Size = new System.Drawing.Size(150, 50);
            this.label12.TabIndex = 211;
            this.label12.Text = "권치수(M)";
            this.label12.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblROLLCNT
            // 
            this.lblROLLCNT.BackColor = System.Drawing.Color.LightGray;
            this.lblROLLCNT.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblROLLCNT.ColorContent = System.Drawing.Color.Transparent;
            this.lblROLLCNT.ColorLabel = System.Drawing.Color.LightGray;
            this.lblROLLCNT.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblROLLCNT.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblROLLCNT.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblROLLCNT.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblROLLCNT.Location = new System.Drawing.Point(170, 552);
            this.lblROLLCNT.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblROLLCNT.MoveControl = null;
            this.lblROLLCNT.Name = "lblROLLCNT";
            this.lblROLLCNT.Size = new System.Drawing.Size(401, 50);
            this.lblROLLCNT.TabIndex = 212;
            this.lblROLLCNT.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblROLLCNT.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblROLLCNT.Click += new System.EventHandler(this.lblWrkQty_Click);
            // 
            // lblPRD_END_TIME
            // 
            this.lblPRD_END_TIME.BackColor = System.Drawing.Color.White;
            this.lblPRD_END_TIME.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblPRD_END_TIME.ColorContent = System.Drawing.Color.Transparent;
            this.lblPRD_END_TIME.ColorLabel = System.Drawing.Color.White;
            this.lblPRD_END_TIME.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblPRD_END_TIME.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPRD_END_TIME.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblPRD_END_TIME.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPRD_END_TIME.Location = new System.Drawing.Point(1075, 494);
            this.lblPRD_END_TIME.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPRD_END_TIME.MoveControl = null;
            this.lblPRD_END_TIME.Name = "lblPRD_END_TIME";
            this.lblPRD_END_TIME.Size = new System.Drawing.Size(180, 50);
            this.lblPRD_END_TIME.TabIndex = 210;
            this.lblPRD_END_TIME.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblPRD_END_TIME.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblPRD_END_TIME.Click += new System.EventHandler(this.lblWorkTime_Click);
            // 
            // dtpPRD_END_DATE
            // 
            this.dtpPRD_END_DATE.CustomFormat = "yyyy-MM-dd";
            this.dtpPRD_END_DATE.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.dtpPRD_END_DATE.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtpPRD_END_DATE.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.dtpPRD_END_DATE.Location = new System.Drawing.Point(742, 494);
            this.dtpPRD_END_DATE.MinimumSize = new System.Drawing.Size(0, 50);
            this.dtpPRD_END_DATE.Name = "dtpPRD_END_DATE";
            this.dtpPRD_END_DATE.ShowUpDown = true;
            this.dtpPRD_END_DATE.Size = new System.Drawing.Size(320, 50);
            this.dtpPRD_END_DATE.TabIndex = 209;
            this.dtpPRD_END_DATE.DropDown += new System.EventHandler(this.dtpDate_DropDown);
            // 
            // label11
            // 
            this.label11.BackColor = System.Drawing.Color.Gray;
            this.label11.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label11.ForeColor = System.Drawing.Color.White;
            this.label11.Location = new System.Drawing.Point(586, 494);
            this.label11.Name = "label11";
            this.label11.Size = new System.Drawing.Size(150, 50);
            this.label11.TabIndex = 208;
            this.label11.Text = "종료일시";
            this.label11.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label10
            // 
            this.label10.BackColor = System.Drawing.Color.Gray;
            this.label10.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label10.ForeColor = System.Drawing.Color.White;
            this.label10.Location = new System.Drawing.Point(15, 494);
            this.label10.Name = "label10";
            this.label10.Size = new System.Drawing.Size(150, 50);
            this.label10.TabIndex = 206;
            this.label10.Text = "평량/지폭";
            this.label10.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblWorkWidth
            // 
            this.lblWorkWidth.BackColor = System.Drawing.Color.White;
            this.lblWorkWidth.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblWorkWidth.ColorContent = System.Drawing.Color.Transparent;
            this.lblWorkWidth.ColorLabel = System.Drawing.Color.White;
            this.lblWorkWidth.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblWorkWidth.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWorkWidth.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblWorkWidth.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWorkWidth.Location = new System.Drawing.Point(375, 494);
            this.lblWorkWidth.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWorkWidth.MoveControl = null;
            this.lblWorkWidth.Name = "lblWorkWidth";
            this.lblWorkWidth.Size = new System.Drawing.Size(195, 50);
            this.lblWorkWidth.TabIndex = 207;
            this.lblWorkWidth.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblWorkWidth.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblWorkWidth.Click += new System.EventHandler(this.lblWorkWidth_Click);
            // 
            // lblPRD_STR_DATE
            // 
            this.lblPRD_STR_DATE.BackColor = System.Drawing.Color.White;
            this.lblPRD_STR_DATE.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblPRD_STR_DATE.ColorContent = System.Drawing.Color.Transparent;
            this.lblPRD_STR_DATE.ColorLabel = System.Drawing.Color.White;
            this.lblPRD_STR_DATE.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblPRD_STR_DATE.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPRD_STR_DATE.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblPRD_STR_DATE.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPRD_STR_DATE.Location = new System.Drawing.Point(1075, 437);
            this.lblPRD_STR_DATE.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPRD_STR_DATE.MoveControl = null;
            this.lblPRD_STR_DATE.Name = "lblPRD_STR_DATE";
            this.lblPRD_STR_DATE.Size = new System.Drawing.Size(180, 50);
            this.lblPRD_STR_DATE.TabIndex = 205;
            this.lblPRD_STR_DATE.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblPRD_STR_DATE.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.lblPRD_STR_DATE.Click += new System.EventHandler(this.lblWorkTime_Click);
            // 
            // dtpPRD_STR_DATE
            // 
            this.dtpPRD_STR_DATE.CustomFormat = "yyyy-MM-dd";
            this.dtpPRD_STR_DATE.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.dtpPRD_STR_DATE.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtpPRD_STR_DATE.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.dtpPRD_STR_DATE.Location = new System.Drawing.Point(742, 437);
            this.dtpPRD_STR_DATE.MinimumSize = new System.Drawing.Size(0, 50);
            this.dtpPRD_STR_DATE.Name = "dtpPRD_STR_DATE";
            this.dtpPRD_STR_DATE.ShowUpDown = true;
            this.dtpPRD_STR_DATE.Size = new System.Drawing.Size(320, 50);
            this.dtpPRD_STR_DATE.TabIndex = 204;
            this.dtpPRD_STR_DATE.DropDown += new System.EventHandler(this.dtpDate_DropDown);
            // 
            // label9
            // 
            this.label9.BackColor = System.Drawing.Color.Gray;
            this.label9.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label9.ForeColor = System.Drawing.Color.White;
            this.label9.Location = new System.Drawing.Point(586, 437);
            this.label9.Name = "label9";
            this.label9.Size = new System.Drawing.Size(150, 50);
            this.label9.TabIndex = 203;
            this.label9.Text = "시작일시";
            this.label9.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label13
            // 
            this.label13.BackColor = System.Drawing.Color.Gray;
            this.label13.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label13.ForeColor = System.Drawing.Color.White;
            this.label13.Location = new System.Drawing.Point(15, 437);
            this.label13.Name = "label13";
            this.label13.Size = new System.Drawing.Size(150, 50);
            this.label13.TabIndex = 201;
            this.label13.Text = "생산실적일자";
            this.label13.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label8
            // 
            this.label8.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(128)))), ((int)(((byte)(0)))));
            this.label8.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label8.ForeColor = System.Drawing.Color.Black;
            this.label8.Location = new System.Drawing.Point(15, 381);
            this.label8.Name = "label8";
            this.label8.Size = new System.Drawing.Size(1240, 50);
            this.label8.TabIndex = 143;
            this.label8.Text = "실적정보";
            this.label8.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // label7
            // 
            this.label7.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(128)))), ((int)(((byte)(0)))));
            this.label7.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label7.ForeColor = System.Drawing.Color.Black;
            this.label7.Location = new System.Drawing.Point(15, 13);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(1240, 50);
            this.label7.TabIndex = 142;
            this.label7.Text = "작업지시정보";
            this.label7.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // label6
            // 
            this.label6.BackColor = System.Drawing.Color.Gray;
            this.label6.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label6.ForeColor = System.Drawing.Color.White;
            this.label6.Location = new System.Drawing.Point(15, 304);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(150, 50);
            this.label6.TabIndex = 140;
            this.label6.Text = "비고";
            this.label6.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblWRK_ORDR_RMK
            // 
            this.lblWRK_ORDR_RMK.BackColor = System.Drawing.Color.LightGray;
            this.lblWRK_ORDR_RMK.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblWRK_ORDR_RMK.ColorContent = System.Drawing.Color.Transparent;
            this.lblWRK_ORDR_RMK.ColorLabel = System.Drawing.Color.LightGray;
            this.lblWRK_ORDR_RMK.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblWRK_ORDR_RMK.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWRK_ORDR_RMK.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblWRK_ORDR_RMK.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWRK_ORDR_RMK.Location = new System.Drawing.Point(171, 304);
            this.lblWRK_ORDR_RMK.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWRK_ORDR_RMK.MoveControl = null;
            this.lblWRK_ORDR_RMK.Name = "lblWRK_ORDR_RMK";
            this.lblWRK_ORDR_RMK.Size = new System.Drawing.Size(1085, 50);
            this.lblWRK_ORDR_RMK.TabIndex = 141;
            this.lblWRK_ORDR_RMK.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblWRK_ORDR_RMK.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label5
            // 
            this.label5.BackColor = System.Drawing.Color.Gray;
            this.label5.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label5.ForeColor = System.Drawing.Color.White;
            this.label5.Location = new System.Drawing.Point(15, 132);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(150, 50);
            this.label5.TabIndex = 138;
            this.label5.Text = "작업지시번호";
            this.label5.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblWRK_ORDR_NO
            // 
            this.lblWRK_ORDR_NO.BackColor = System.Drawing.Color.LightGray;
            this.lblWRK_ORDR_NO.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblWRK_ORDR_NO.ColorContent = System.Drawing.Color.Transparent;
            this.lblWRK_ORDR_NO.ColorLabel = System.Drawing.Color.LightGray;
            this.lblWRK_ORDR_NO.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblWRK_ORDR_NO.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWRK_ORDR_NO.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblWRK_ORDR_NO.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWRK_ORDR_NO.Location = new System.Drawing.Point(171, 133);
            this.lblWRK_ORDR_NO.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWRK_ORDR_NO.MoveControl = null;
            this.lblWRK_ORDR_NO.Name = "lblWRK_ORDR_NO";
            this.lblWRK_ORDR_NO.Size = new System.Drawing.Size(480, 50);
            this.lblWRK_ORDR_NO.TabIndex = 139;
            this.lblWRK_ORDR_NO.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblWRK_ORDR_NO.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // label4
            // 
            this.label4.BackColor = System.Drawing.Color.Gray;
            this.label4.Font = new System.Drawing.Font("맑은 고딕", 24F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label4.ForeColor = System.Drawing.Color.White;
            this.label4.Location = new System.Drawing.Point(847, 76);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(150, 110);
            this.label4.TabIndex = 136;
            this.label4.Text = "계획량";
            this.label4.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblORDER_QTY
            // 
            this.lblORDER_QTY.BackColor = System.Drawing.Color.LightGray;
            this.lblORDER_QTY.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblORDER_QTY.ColorContent = System.Drawing.Color.Transparent;
            this.lblORDER_QTY.ColorLabel = System.Drawing.Color.LightGray;
            this.lblORDER_QTY.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblORDER_QTY.Font = new System.Drawing.Font("맑은 고딕", 24F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblORDER_QTY.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblORDER_QTY.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblORDER_QTY.Location = new System.Drawing.Point(1005, 76);
            this.lblORDER_QTY.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblORDER_QTY.MoveControl = null;
            this.lblORDER_QTY.Name = "lblORDER_QTY";
            this.lblORDER_QTY.Size = new System.Drawing.Size(250, 110);
            this.lblORDER_QTY.TabIndex = 137;
            this.lblORDER_QTY.TextHAlign = Infragistics.Win.HAlign.Right;
            this.lblORDER_QTY.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblPRD_REQ_DT
            // 
            this.lblPRD_REQ_DT.BackColor = System.Drawing.Color.LightGray;
            this.lblPRD_REQ_DT.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblPRD_REQ_DT.ColorContent = System.Drawing.Color.Transparent;
            this.lblPRD_REQ_DT.ColorLabel = System.Drawing.Color.LightGray;
            this.lblPRD_REQ_DT.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblPRD_REQ_DT.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblPRD_REQ_DT.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblPRD_REQ_DT.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblPRD_REQ_DT.Location = new System.Drawing.Point(171, 76);
            this.lblPRD_REQ_DT.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblPRD_REQ_DT.MoveControl = null;
            this.lblPRD_REQ_DT.Name = "lblPRD_REQ_DT";
            this.lblPRD_REQ_DT.Size = new System.Drawing.Size(670, 50);
            this.lblPRD_REQ_DT.TabIndex = 135;
            this.lblPRD_REQ_DT.TextHAlign = Infragistics.Win.HAlign.Left;
            this.lblPRD_REQ_DT.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblWRK_ORDR_SEQNO
            // 
            this.lblWRK_ORDR_SEQNO.BackColor = System.Drawing.Color.LightGray;
            this.lblWRK_ORDR_SEQNO.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblWRK_ORDR_SEQNO.ColorContent = System.Drawing.Color.Transparent;
            this.lblWRK_ORDR_SEQNO.ColorLabel = System.Drawing.Color.LightGray;
            this.lblWRK_ORDR_SEQNO.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblWRK_ORDR_SEQNO.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblWRK_ORDR_SEQNO.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblWRK_ORDR_SEQNO.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblWRK_ORDR_SEQNO.Location = new System.Drawing.Point(661, 132);
            this.lblWRK_ORDR_SEQNO.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblWRK_ORDR_SEQNO.MoveControl = null;
            this.lblWRK_ORDR_SEQNO.Name = "lblWRK_ORDR_SEQNO";
            this.lblWRK_ORDR_SEQNO.Size = new System.Drawing.Size(180, 50);
            this.lblWRK_ORDR_SEQNO.TabIndex = 134;
            this.lblWRK_ORDR_SEQNO.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblWRK_ORDR_SEQNO.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblMATNR_SPEC
            // 
            this.lblMATNR_SPEC.BackColor = System.Drawing.Color.LightGray;
            this.lblMATNR_SPEC.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblMATNR_SPEC.ColorContent = System.Drawing.Color.Transparent;
            this.lblMATNR_SPEC.ColorLabel = System.Drawing.Color.LightGray;
            this.lblMATNR_SPEC.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblMATNR_SPEC.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblMATNR_SPEC.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblMATNR_SPEC.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblMATNR_SPEC.Location = new System.Drawing.Point(845, 190);
            this.lblMATNR_SPEC.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblMATNR_SPEC.MoveControl = null;
            this.lblMATNR_SPEC.Name = "lblMATNR_SPEC";
            this.lblMATNR_SPEC.Size = new System.Drawing.Size(410, 50);
            this.lblMATNR_SPEC.TabIndex = 128;
            this.lblMATNR_SPEC.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblMATNR_SPEC.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // POP_WRK12
            // 
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
            this.BackColor = System.Drawing.Color.White;
            this.ClientSize = new System.Drawing.Size(1280, 1024);
            this.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.Name = "POP_WRK12";
            this.SyncTime = true;
            this.Text = "현장 단말 메인";
            this.Load += new System.EventHandler(this.POP_WRK12_Load);
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
        private MESLabel lblSPEC;
        private System.Windows.Forms.Label label3;
        private MESLabel lblMATNR;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.SplitContainer splitContainer1;
        private ButtonBox bBox1;
        private MESLabel lblMATNR_SPEC;
        private MESLabel lblWRK_ORDR_SEQNO;
        private System.Windows.Forms.Label label5;
        private MESLabel lblWRK_ORDR_NO;
        private System.Windows.Forms.Label label4;
        private MESLabel lblORDER_QTY;
        private MESLabel lblPRD_REQ_DT;
        private System.Windows.Forms.Label label6;
        private MESLabel lblWRK_ORDR_RMK;
        private System.Windows.Forms.Label label7;
        private System.Windows.Forms.Label label8;
        private System.Windows.Forms.Label label17;
        private System.Windows.Forms.Label label16;
        private MESLabel lblWorkSpeed;
        private System.Windows.Forms.Label label15;
        private MESLabel lblTM;
        private System.Windows.Forms.Label label14;
        private MESLabel lblWGT;
        private System.Windows.Forms.Label label12;
        private MESLabel lblROLLCNT;
        private MESLabel lblPRD_END_TIME;
        private System.Windows.Forms.DateTimePicker dtpPRD_END_DATE;
        private System.Windows.Forms.Label label11;
        private MESLabel lblPRD_STR_DATE;
        private System.Windows.Forms.DateTimePicker dtpPRD_STR_DATE;
        private System.Windows.Forms.Label label9;
        private System.Windows.Forms.Button PRD_END_DATE;
        private System.Windows.Forms.Button butPRD_STR_DATE;
        private System.Windows.Forms.Label label10;
        private MESLabel lblWorkWidth;
        private System.Windows.Forms.Label label13;
        private System.Windows.Forms.TextBox txtRMK;
        private MESLabel lblPRFM_DT;
        private MESLabel lblBSWGT;
        private MESLabel lblMulCnt;

    }
}
