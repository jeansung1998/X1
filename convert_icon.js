const sharp = require('sharp');

const svg = `<svg width="1024" height="1024" viewBox="0 0 680 680" role="img" xmlns="http://www.w3.org/2000/svg">
<defs>
  <radialGradient id="bg7" cx="40%" cy="35%" r="65%">
    <stop offset="0%" stop-color="#2a2a2a"/>
    <stop offset="100%" stop-color="#080808"/>
  </radialGradient>
  <radialGradient id="lens7" cx="38%" cy="32%" r="60%">
    <stop offset="0%" stop-color="#3a3a3a"/>
    <stop offset="60%" stop-color="#161616"/>
    <stop offset="100%" stop-color="#0a0a0a"/>
  </radialGradient>
  <radialGradient id="inner7" cx="36%" cy="30%" r="55%">
    <stop offset="0%" stop-color="#1e1e1e"/>
    <stop offset="100%" stop-color="#050505"/>
  </radialGradient>
  <radialGradient id="shine7" cx="30%" cy="25%" r="40%">
    <stop offset="0%" stop-color="#ffffff" stop-opacity="0.18"/>
    <stop offset="100%" stop-color="#ffffff" stop-opacity="0"/>
  </radialGradient>
  <radialGradient id="ring1g" cx="50%" cy="50%" r="50%">
    <stop offset="80%" stop-color="#333333" stop-opacity="0"/>
    <stop offset="90%" stop-color="#555555" stop-opacity="0.6"/>
    <stop offset="100%" stop-color="#222222" stop-opacity="0"/>
  </radialGradient>
  <radialGradient id="ring2g" cx="50%" cy="50%" r="50%">
    <stop offset="75%" stop-color="#444444" stop-opacity="0"/>
    <stop offset="85%" stop-color="#666666" stop-opacity="0.4"/>
    <stop offset="100%" stop-color="#222222" stop-opacity="0"/>
  </radialGradient>
</defs>
<rect x="40" y="40" width="600" height="600" rx="120" fill="url(#bg7)"/>
<ellipse cx="340" cy="340" rx="248" ry="248" fill="url(#ring1g)"/>
<ellipse cx="340" cy="340" rx="230" ry="230" fill="url(#ring2g)"/>
<ellipse cx="340" cy="340" rx="220" ry="220" fill="#181818" stroke="#3a3a3a" stroke-width="2"/>
<ellipse cx="340" cy="340" rx="220" ry="220" fill="none" stroke="#555555" stroke-width="1" stroke-dasharray="60 1000" stroke-dashoffset="-40"/>
<ellipse cx="340" cy="340" rx="188" ry="188" fill="url(#lens7)" stroke="#2e2e2e" stroke-width="1.5"/>
<ellipse cx="340" cy="340" rx="155" ry="155" fill="url(#inner7)" stroke="#282828" stroke-width="1.5"/>
<ellipse cx="340" cy="340" rx="122" ry="122" fill="#0c0c0c" stroke="#1e1e1e" stroke-width="1"/>
<ellipse cx="340" cy="340" rx="122" ry="122" fill="url(#shine7)"/>
<path d="M 266 256 Q 310 230 355 248" fill="none" stroke="#ffffff" stroke-width="1.5" stroke-linecap="round" stroke-opacity="0.25"/>
<text x="352" y="570" font-family="Georgia, serif" font-size="460" font-weight="700" fill="#505050" text-anchor="middle">R</text>
<text x="346" y="564" font-family="Georgia, serif" font-size="460" font-weight="700" fill="#474747" text-anchor="middle">R</text>
<text x="340" y="558" font-family="Georgia, serif" font-size="460" font-weight="700" fill="#3e3e3e" text-anchor="middle">R</text>
<text x="334" y="550" font-family="Georgia, serif" font-size="460" font-weight="700" fill="#f2f2f2" text-anchor="middle">R</text>
<text x="334" y="550" font-family="Georgia, serif" font-size="460" font-weight="700" fill="#ffffff" fill-opacity="0.15" text-anchor="middle">R</text>
<circle cx="460" cy="222" r="5" fill="#ffffff" fill-opacity="0.35"/>
<circle cx="460" cy="222" r="12" fill="#ffffff" fill-opacity="0.06"/>
<circle cx="424" cy="198" r="2.5" fill="#ffffff" fill-opacity="0.25"/>
<path d="M 168 430 Q 340 510 512 430" fill="none" stroke="#3a3a3a" stroke-width="1" stroke-linecap="round" stroke-opacity="0.5"/>
</svg>`;

sharp(Buffer.from(svg))
  .resize(1024, 1024)
  .png()
  .toFile('icon.png')
  .then(() => console.log('icon.png 생성 완료 (1024x1024)'))
  .catch(err => console.error(err));