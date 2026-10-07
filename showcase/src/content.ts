// All page copy lives here (Thai + English) so text can be edited without
// touching layout code.

export type Lang = 'th' | 'en'

export const links = {
  repo: 'https://github.com/putianan65/employee_task_tracker',
  readmeEn: 'https://github.com/putianan65/employee_task_tracker#readme',
  readmeTh: 'https://github.com/putianan65/employee_task_tracker/blob/main/README_TH.md',
  profile: 'https://github.com/putianan65',
}

export const author = {
  handle: 'putianan65',
  avatar: 'https://avatars.githubusercontent.com/putianan65?s=320',
}

// Hero background video from the original NovaAI landing page (see Credits).
export const heroVideoSrc =
  'https://d8j0ntlcm91z4.cloudfront.net/user_38xzZboKViGWJOttwIXH07lWA1P/hf_20260729_102822_0e6c87e8-c141-4744-bf32-ad30db296371.mp4'

export const screens = {
  login: 'screens/01-login.webp',
  newTask: 'screens/02-admin-new-task.webp',
  taskDetail: 'screens/03-task-detail.webp',
  notifications: 'screens/04-admin-notifications.webp',
  mobileList: 'screens/m-03a-employee-list.webp',
  mobileDetail: 'screens/m-03-task-detail.webp',
}

type Item = { title: string; body: string }

export type Copy = {
  title: string
  nav: { links: { label: string; href: string; count?: number }[]; cta: string }
  hero: {
    services: string[]
    intro: string
    badge: string
    headline: [string, string]
    builtBy: string
    cardMeta: string
    cardCta: string
  }
  why: {
    badge: string
    intro: string
    headline: [string, string]
    body: string
    primary: string
    secondary: string
    items: Item[]
  }
  walkthrough: {
    badge: string
    headline: [string, string]
    intro: string
    stepLabel: string
    note: string
    steps: (Item & { role: string; tags: string[]; image: string; alt: string })[]
  }
  features: {
    badge: string
    headline: [string, string]
    body: string
    mobileCaption: string
    mobileAlt: [string, string]
    items: Item[]
  }
  stack: {
    badge: string
    headline: [string, string]
    body: string
    items: { label: string; value: string }[]
    learningsLabel: string
    learnings: string[]
  }
  footer: {
    tagline: string
    readmeEn: string
    readmeTh: string
    profile: string
    creditsLabel: string
    credits: { label: string; body: string }[]
    rights: string
    adapted: string
  }
}

// Chrome's Thai line breaker splits this loanword mid-word ("โปร|เจ|กต์");
// WORD JOINERs between its syllables keep it on one line.
const project = 'โปร\u2060เจ\u2060กต์'

const stackItems = [
  { label: 'Framework', value: 'Flutter · Dart SDK ^3.7.2' },
  { label: 'Auth', value: 'Firebase Auth' },
  { label: 'Database', value: 'Cloud Firestore (real-time)' },
  { label: 'Maps', value: 'google_maps_flutter · geolocator' },
  { label: 'Utilities', value: 'intl · url_launcher' },
  { label: 'Architecture', value: 'Models · Services · Screens · Widgets' },
]

export const copy: Record<Lang, Copy> = {
  th: {
    title: 'TASK_TRACKER — มอบหมาย ติดตาม จนงานเสร็จ',
    nav: {
      links: [
        { label: 'แก้ปัญหาอะไร', href: '#why' },
        { label: 'วิธีใช้งาน', href: '#walkthrough' },
        { label: 'ฟีเจอร์', href: '#features', count: 10 },
        { label: 'เครดิต', href: '#credits' },
      ],
      cta: 'ดูบน GitHub',
    },
    hero: {
      services: ['Flutter & Dart', 'Firebase Auth + Firestore', 'ระบบงานตามบทบาท'],
      intro:
        `มินิ${project} Flutter ที่ช่วยให้ทีมเห็นงานทั้งหมดได้ชัดเจน เป็นระบบ และอัปเดตแบบเรียลไทม์`,
      badge: 'สร้างเพื่อเรียนรู้ Flutter',
      headline: ['มอบหมาย ติดตาม', 'จนงานเสร็จ'],
      builtBy: 'พัฒนาโดย',
      cardMeta: 'Flutter · Firebase',
      cardCta: 'ดูซอร์สโค้ด',
    },
    why: {
      badge: `ปัญหาที่${project}นี้แก้`,
      intro:
        'งานที่สั่งผ่านแชทกลุ่มหรือสเปรดชีตมักจมหาย ไม่รู้ว่าใครรับผิดชอบ และต้องคอยไล่ถามสถานะอยู่เสมอ',
      headline: ['รวมทุกงาน', 'ไว้ในที่เดียว'],
      body: 'Employee Task Tracker รวมงาน ผู้รับผิดชอบ สถานะ และตำแหน่งของงานไว้ในรายการเดียวที่อัปเดตแบบเรียลไทม์ — แอดมินไม่ต้องไล่ถามความคืบหน้า ส่วนพนักงานก็รู้เสมอว่าต้องทำอะไรต่อ',
      primary: 'ดูวิธีใช้งาน',
      secondary: 'สำรวจโค้ด',
      items: [
        {
          title: 'ใครรับผิดชอบงานนี้?',
          body: 'แอดมินมอบหมายงานให้แต่ละคนได้ พนักงานจะเห็นเฉพาะงานที่ได้รับมอบหมายเท่านั้น',
        },
        {
          title: 'งานเสร็จหรือยัง?',
          body: 'สถานะงานซิงก์แบบเรียลไทม์ และแจ้งเตือนแอดมินทันทีที่มีการเปลี่ยนแปลง',
        },
        {
          title: 'งานอยู่ตรงไหน?',
          body: 'ปักหมุด GPS ให้แต่ละงานได้ และดูตำแหน่งบน Google Maps รอบพื้นที่ GIST NU',
        },
      ],
    },
    walkthrough: {
      badge: 'วิธีใช้งาน',
      headline: ['ตั้งแต่ล็อกอิน', 'จนงานเสร็จ'],
      intro: 'สองบทบาท สี่ขั้นตอน และข้อมูลชุดเดียวที่อัปเดตตลอดเวลา',
      stepLabel: 'ขั้นตอน',
      note: 'ภาพทั้งหมดเป็นหน้าจอจริงของแอป รันบน Flutter Web กับ Firebase Emulator และข้อมูลตัวอย่าง',
      steps: [
        {
          role: 'ทุกคน',
          title: 'เข้าสู่ระบบ',
          body: 'ล็อกอินด้วยอีเมลและรหัสผ่านผ่าน Firebase Auth สมัครสมาชิกใหม่ หรือขอลิงก์รีเซ็ตรหัสผ่านได้ ทุกบัญชีมีบทบาท admin หรือ employee เก็บไว้ใน Firestore',
          tags: ['Firebase Auth', 'Password reset'],
          image: screens.login,
          alt: 'หน้าเข้าสู่ระบบ มีช่องกรอกอีเมลและรหัสผ่าน',
        },
        {
          role: 'แอดมิน',
          title: 'มอบหมายงาน',
          body: 'สร้างงานพร้อมชื่อ รายละเอียด ผู้รับผิดชอบ ระดับความสำคัญ และตำแหน่ง GPS (ถ้ามี) งานจะขึ้นในรายการของพนักงานที่ได้รับมอบหมายทันที',
          tags: ['CRUD', 'Priority', 'GPS'],
          image: screens.newTask,
          alt: 'แอดมินกำลังสร้างงานใหม่ในหน้าต่าง Add New Task',
        },
        {
          role: 'พนักงาน',
          title: 'ลงมือทำงาน',
          body: 'พนักงานเห็นเฉพาะงานของตัวเอง เปิดงานเพื่อติ๊ก Checklist คุยกับทีมในแชทของงานพร้อม Emoji Reaction แล้วเปลี่ยนสถานะจาก To Do → In Progress → Done',
          tags: ['Checklist', 'Task chat', 'Status'],
          image: screens.taskDetail,
          alt: 'หน้ารายละเอียดงาน มี Checklist แชท และบันทึกกิจกรรม',
        },
        {
          role: 'แอดมิน',
          title: 'ติดตามความคืบหน้า',
          body: 'ทุกการเปลี่ยนสถานะจะเข้ากล่องแจ้งเตือนของแอดมินแบบเรียลไทม์ พร้อมตัวเลขบอกจำนวนที่ยังไม่อ่าน — ไม่ต้องไล่ถามความคืบหน้าอีกต่อไป',
          tags: ['Real-time', 'Notifications'],
          image: screens.notifications,
          alt: 'กล่องแจ้งเตือนของแอดมินแสดงการเปลี่ยนสถานะงาน',
        },
      ],
    },
    features: {
      badge: 'ฟีเจอร์ทั้งหมด',
      headline: ['ครบทุกอย่าง', 'ที่ทีมต้องใช้'],
      body: `สร้างขึ้นระหว่างรอ Requirement ของ${project}จริง — เป็นการลงมือเรียนรู้ทั้งระบบล็อกอิน CRUD แชท Checklist การแจ้งเตือน และแผนที่ ในโค้ด Flutter ชุดเดียว`,
      mobileCaption: 'โค้ดชุดเดียวกัน ใช้งานบนมือถือได้',
      mobileAlt: ['รายการงานของพนักงานบนมือถือ', 'รายละเอียดงานบนมือถือ'],
      items: [
        { title: 'ระบบยืนยันตัวตน', body: 'ล็อกอิน สมัครสมาชิก และรีเซ็ตรหัสผ่านด้วย Firebase Auth' },
        { title: 'สิทธิ์ตามบทบาท', body: 'Admin เห็นทุกงาน ส่วน Employee เห็นเฉพาะงานของตัวเอง' },
        { title: 'จัดการงาน', body: 'สร้าง แก้ไข มอบหมาย อัปเดต และลบงาน (CRUD) ครบ' },
        { title: 'ติดตามสถานะ', body: 'To Do → In Progress → Done เปลี่ยนได้จากการ์ดงาน' },
        { title: 'ซิงก์แบบเรียลไทม์', body: 'StreamBuilder + Firestore Streams ทำให้ทุกหน้าจออัปเดตทันที' },
        { title: 'แจ้งเตือนในแอป', body: 'แอดมินได้รับแจ้งเตือนทันทีเมื่อสถานะงานเปลี่ยน พร้อมตัวเลขที่ยังไม่อ่าน' },
        { title: 'แชทในงาน', body: 'ห้องสนทนาของแต่ละงาน กด Emoji Reaction ให้แต่ละข้อความได้' },
        { title: 'Checklist', body: 'แบ่งงานย่อยภายในงาน ติดตามความคืบหน้าได้ละเอียดขึ้น' },
        { title: 'แผนที่', body: 'แสดงงานที่มีตำแหน่งเป็น Marker บน Google Maps' },
        { title: 'บันทึกกิจกรรม', body: 'เก็บประวัติทุกการกระทำในงาน ว่าใครทำอะไร เมื่อไร' },
      ],
    },
    stack: {
      badge: 'เบื้องหลัง',
      headline: [`${project}เล็ก`, 'แต่ใช้ของจริง'],
      body: 'แยกโค้ดเป็น Models, Services, Screens และ Widgets ให้อ่านง่ายและต่อยอดได้ ข้อมูลทั้งหมดไหลผ่าน Firestore Streams',
      items: stackItems,
      learningsLabel: 'สิ่งที่ได้เรียนรู้',
      learnings: [
        'การเชื่อมต่อ Firebase',
        'จัดการ State ด้วย StreamBuilder',
        'Role-Based Access Control',
        'CRUD กับ Firestore',
        'Google Maps Marker',
        `โครงสร้าง${project}ที่เป็นระเบียบ`,
      ],
    },
    footer: {
      tagline: `Employee Task Tracker — ${project} Flutter เพื่อการศึกษา`,
      readmeEn: 'README (EN)',
      readmeTh: 'README (TH)',
      profile: 'โปรไฟล์ GitHub',
      creditsLabel: 'เครดิต',
      credits: [
        {
          label: 'ดีไซน์',
          body: 'เลย์เอาต์ โมชัน และสไตล์กระจกฝ้า ดัดแปลงมาจากแลนดิ้งเพจ “NovaAI — Today AI Aligns With Bold Dreams” (Exact-recreation prompt) เครดิตการออกแบบทั้งหมดเป็นของผู้สร้างต้นฉบับ',
        },
        {
          label: 'วิดีโอพื้นหลัง',
          body: 'ภาพเรนเดอร์ 3D สตรีมจาก CDN ของต้นฉบับ NovaAI © ผู้สร้างต้นฉบับ — ไม่ได้นำไฟล์มาเผยแพร่ซ้ำใน Repository นี้',
        },
        {
          label: 'ฟอนต์',
          body: 'Inter โดย Rasmus Andersson และ IBM Plex Sans Thai โดย IBM (SIL Open Font License) ผ่าน Google Fonts',
        },
        { label: 'ไอคอน', body: 'Lucide (ISC License)' },
        { label: 'โลโก้', body: 'โลโก้ GIST NU ภายในแอปเป็นของ GIST NU มหาวิทยาลัยนเรศวร' },
      ],
      rights: `${project}นี้จัดทำเพื่อการศึกษาเท่านั้น ไม่ใช่แอปสำหรับใช้งานจริง`,
      adapted: 'ดีไซน์ดัดแปลงจาก NovaAI',
    },
  },

  en: {
    title: 'TASK_TRACKER — Assigned. Tracked. Done.',
    nav: {
      links: [
        { label: 'Why', href: '#why' },
        { label: 'Walkthrough', href: '#walkthrough' },
        { label: 'Features', href: '#features', count: 10 },
        { label: 'Credits', href: '#credits' },
      ],
      cta: 'View on GitHub',
    },
    hero: {
      services: ['Flutter & Dart', 'Firebase Auth + Firestore', 'Role-Based Task Flow'],
      intro:
        'A Flutter mini-project that brings clarity, structure, and real-time visibility to the way a team tracks its work.',
      badge: 'Built To Learn Flutter',
      headline: ['Assigned. Tracked.', 'Done.'],
      builtBy: 'Built by',
      cardMeta: 'Flutter · Firebase',
      cardCta: 'View source code',
    },
    why: {
      badge: 'The Problem It Solves',
      intro:
        'Work handed out in group chats and spreadsheets gets buried — status is guesswork and nobody is sure who owns what.',
      headline: ['One list.', 'Every answer.'],
      body: 'Employee Task Tracker keeps every task, its owner, its status and its location in one real-time list — so admins stop chasing updates and employees always know what’s next.',
      primary: 'See how it works',
      secondary: 'Explore the code',
      items: [
        {
          title: 'Who is on it?',
          body: 'Admins assign every task to a person; employees only see the work assigned to them.',
        },
        {
          title: 'Is it done yet?',
          body: 'Status syncs in real time and notifies the admin the moment it changes.',
        },
        {
          title: 'Where is the job?',
          body: 'Tasks carry GPS pins and show up on Google Maps around the GIST NU campus.',
        },
      ],
    },
    walkthrough: {
      badge: 'How It Works',
      headline: ['From sign-in', 'to done.'],
      intro: 'Two roles, four steps, one source of truth that never goes stale.',
      stepLabel: 'Step',
      note: 'Every image is a real screen from the app, running on Flutter Web against the Firebase Emulator with demo data.',
      steps: [
        {
          role: 'Everyone',
          title: 'Sign in',
          body: 'Log in with email and password through Firebase Auth, create an account, or request a password-reset link. Every account carries a role — admin or employee — stored in Firestore.',
          tags: ['Firebase Auth', 'Password reset'],
          image: screens.login,
          alt: 'Login screen with email and password fields',
        },
        {
          role: 'Admin',
          title: 'Assign the work',
          body: 'Create a task with a title, description, assignee, priority and an optional GPS location. It shows up in the assigned employee’s task list immediately.',
          tags: ['CRUD', 'Priority', 'GPS'],
          image: screens.newTask,
          alt: 'Admin creating a new task in the Add New Task dialog',
        },
        {
          role: 'Employee',
          title: 'Do the work',
          body: 'Employees only see their own tasks. Open one to tick off the checklist, talk it through in the task chat with emoji reactions, and move it from To Do → In Progress → Done.',
          tags: ['Checklist', 'Task chat', 'Status'],
          image: screens.taskDetail,
          alt: 'Task detail dialog with checklist, chat and activity log',
        },
        {
          role: 'Admin',
          title: 'Track progress',
          body: 'Every status change shows up in the admin’s notification inbox in real time, with an unread badge — no more chasing people for updates.',
          tags: ['Real-time', 'Notifications'],
          image: screens.notifications,
          alt: 'Admin notification inbox listing status changes',
        },
      ],
    },
    features: {
      badge: 'Feature Index',
      headline: ['Everything', 'a team needs.'],
      body: 'Built while waiting on a real project’s requirements — a hands-on tour of auth, CRUD, chat, checklists, notifications and maps in one Flutter codebase.',
      mobileCaption: 'Same Flutter code, on a phone',
      mobileAlt: ['Employee task list on a phone', 'Task detail on a phone'],
      items: [
        { title: 'Authentication', body: 'Email sign-in, registration and password reset with Firebase Auth.' },
        { title: 'Role-based access', body: 'Admin sees everything; Employee sees only assigned tasks.' },
        { title: 'Task management', body: 'Create, edit, assign, update and delete — full CRUD.' },
        { title: 'Status tracking', body: 'To Do → In Progress → Done, one tap from the task card.' },
        { title: 'Real-time sync', body: 'StreamBuilder + Firestore streams keep every screen live.' },
        { title: 'In-app notifications', body: 'Admins are alerted the moment a task’s status changes.' },
        { title: 'Task chat', body: 'A message thread per task, with emoji reactions on every message.' },
        { title: 'Checklists', body: 'Sub-tasks inside each task for finer-grained progress.' },
        { title: 'Map view', body: 'Google Maps markers for every task that has a location.' },
        { title: 'Activity log', body: 'Every action on a task, recorded with who and when.' },
      ],
    },
    stack: {
      badge: 'Under The Hood',
      headline: ['Small project.', 'Real stack.'],
      body: 'Code is split into models, services, screens and widgets so it stays readable, and every piece of data flows through Firestore streams.',
      items: stackItems,
      learningsLabel: 'What I learned',
      learnings: [
        'Firebase integration',
        'StreamBuilder state',
        'Role-based access control',
        'CRUD with Firestore',
        'Google Maps markers',
        'Clean project structure',
      ],
    },
    footer: {
      tagline: 'Employee Task Tracker — an educational Flutter project.',
      readmeEn: 'README (EN)',
      readmeTh: 'README (TH)',
      profile: 'GitHub profile',
      creditsLabel: 'Credits',
      credits: [
        {
          label: 'Design',
          body: 'Layout, motion and glass system adapted from the “NovaAI — Today AI Aligns With Bold Dreams” landing page (exact-recreation prompt). All design credit goes to its original creator.',
        },
        {
          label: 'Hero video',
          body: 'Abstract 3D render streamed from the original NovaAI CDN. © its original creator — not redistributed in this repository.',
        },
        {
          label: 'Typefaces',
          body: 'Inter by Rasmus Andersson and IBM Plex Sans Thai by IBM, SIL Open Font License, served by Google Fonts.',
        },
        { label: 'Icons', body: 'Lucide, ISC License.' },
        { label: 'Logo', body: 'The GIST NU logo inside the app belongs to GIST NU, Naresuan University.' },
      ],
      rights: 'For educational purposes only — not a production application.',
      adapted: 'Design adapted from NovaAI',
    },
  },
}
